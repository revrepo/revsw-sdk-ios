// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "quic_spdy_client_stream.h"
#include "base/logging.h"
#include "base/stl_util.h"
#include "base/strings/string_number_conversions.h"
#include "net/spdy/spdy_protocol.h"
#include "quic_client_session.h"

#include "base/stl_util.h"
#include "base/strings/string_number_conversions.h"
#include "base/strings/string_split.h"
#include "net/spdy/spdy_frame_builder.h"
#include "net/spdy/spdy_framer.h"
#include "net/spdy/spdy_protocol.h"
#include <vector>

using namespace std;
using base::StringPiece;
using std::string;
using base::StringToInt;

namespace net {
    namespace tools {
        
        static bool ParseHeaders(const char* data,
                                 uint32_t data_len,
                                 int* content_length,
                                 SpdyHeaderBlock* headers) {
            SpdyFramer framer(HTTP2);
            if (!framer.ParseHeaderBlockInBuffer(data, data_len, headers) ||
                headers->empty()) {
                return false;  // Headers were invalid.
            }
            if (ContainsKey(*headers, "content-length")) {
                // Check whether multiple values are consistent.
                base::StringPiece content_length_header = (*headers)["content-length"];
                vector<string> values =
                base::SplitString(content_length_header, base::StringPiece("\0", 1),
                                  base::TRIM_WHITESPACE, base::SPLIT_WANT_ALL);
                for (const string& value : values) {
                    int new_value;
                    if (!base::StringToInt(value, &new_value) || new_value < 0) {
                        return false;
                    }
                    if (*content_length < 0) {
                        *content_length = new_value;
                        continue;
                    }
                    if (new_value != *content_length) {
                        return false;
                    }
                }
            }
            return true;
        }
        
        static bool ParseTrailers(const char* data,
                                  uint32_t data_len,
                                  size_t* final_byte_offset,
                                  SpdyHeaderBlock* trailers) {
            SpdyFramer framer(HTTP2);
            if (!framer.ParseHeaderBlockInBuffer(data, data_len, trailers) ||
                trailers->empty()) {
                DVLOG(1) << "Request Trailers are invalid.";
                return false;  // Trailers were invalid.
            }
            // Pull out the final offset pseudo header which indicates the number of
            // response body bytes expected.
            auto it = trailers->find(kFinalOffsetHeaderKey);
            if (it == trailers->end() ||
                !base::StringToSizeT(it->second, final_byte_offset)) {
                DVLOG(1) << "Required key '" << kFinalOffsetHeaderKey << "' not present";
                return false;
            }
            // The final offset header is no longer needed.
            trailers->erase(it->first);
            // Trailers must not have empty keys, and must not contain pseudo headers.
            for (const auto& trailer : *trailers) {
                base::StringPiece key = trailer.first;
                base::StringPiece value = trailer.second;
                if (key.starts_with(":")) {
                    DVLOG(1) << "Trailers must not contain pseudo-header: '" << key << "','"
                    << value << "'.";
                    return false;
                }
                // TODO(rjshade): Check for other forbidden keys, following the HTTP/2 spec.
            }
            DVLOG(1) << "Successfully parsed Trailers.";
            return true;
        }
        
        
        
        
        QuicSpdyClientStream::QuicSpdyClientStream(QuicStreamId id,
                                                   QuicClientSession* session)
        : QuicSpdyStream(id, session),
        content_length_(-1),
        response_code_(0),
        header_bytes_read_(0),
        header_bytes_written_(0),
        allow_bidirectional_data_(false), data_length_(0) {}
        QuicSpdyClientStream::~QuicSpdyClientStream() {}
        void QuicSpdyClientStream::OnStreamFrame(const QuicStreamFrame& frame) {
            if (!allow_bidirectional_data_ && !write_side_closed()) {
                DVLOG(1) << "Got a response before the request was complete.  "
                << "Aborting request.";
                CloseWriteSide();
            }
            QuicSpdyStream::OnStreamFrame(frame);
        }
        void QuicSpdyClientStream::OnInitialHeadersComplete(bool fin,
                                                            size_t frame_len) {
            QuicSpdyStream::OnInitialHeadersComplete(fin, frame_len);
            DCHECK(headers_decompressed());
            header_bytes_read_ = frame_len;
            if (!ParseHeaders(decompressed_headers().data(),
                              decompressed_headers().length(),
                              &content_length_, &response_headers_)) {
                Reset(QUIC_BAD_APPLICATION_PAYLOAD);
                return;
            }
            string status = response_headers_[":status"].as_string();
            size_t end = status.find(" ");
            if (end != string::npos) {
                status.erase(end);
            }
            if (!StringToInt(status, &response_code_)) {
                // Invalid response code.
                Reset(QUIC_BAD_APPLICATION_PAYLOAD);
                return;
            }
            MarkHeadersConsumed(decompressed_headers().length());
        }
        void QuicSpdyClientStream::OnTrailingHeadersComplete(bool fin,
                                                             size_t frame_len) {
            QuicSpdyStream::OnTrailingHeadersComplete(fin, frame_len);
            size_t final_byte_offset = 0;
            if (!ParseTrailers(decompressed_trailers().data(),
                               decompressed_trailers().length(),
                               &final_byte_offset, &response_trailers_)) {
                Reset(QUIC_BAD_APPLICATION_PAYLOAD);
                return;
            }
            MarkTrailersConsumed(decompressed_trailers().length());
            // The data on this stream ends at |final_byte_offset|.
            DVLOG(1) << "Stream ends at byte offset: " << final_byte_offset
            << "  currently read: " << stream_bytes_read();
            OnStreamFrame(
                          QuicStreamFrame(id(), /*fin=*/true, final_byte_offset, StringPiece()));
        }
        void QuicSpdyClientStream::OnDataAvailable() {
            while (HasBytesToRead()) {
                struct iovec iov;
                if (GetReadableRegions(&iov, 1) == 0) {
                    // No more data to read.
                    break;
                }
                DVLOG(1) << "Client processed " << iov.iov_len << " bytes for stream "
                << id();
                //data_.append(static_cast<char*>(iov.iov_base), iov.iov_len);
                add_incoming_data(iov.iov_base, iov.iov_len);
                if (content_length_ >= 0 &&
                    static_cast<int>(data_length()) > content_length_) {
                    Reset(QUIC_BAD_APPLICATION_PAYLOAD);
                    return;
                }
                MarkConsumed(iov.iov_len);
            }
            if (sequencer()->IsClosed()) {
                OnFinRead();
            } else {
                sequencer()->SetUnblocked();
            }
        }
        
        void QuicSpdyClientStream::add_incoming_data(const void *aData, size_t aSize)
        {
            if (should_add_incoming_data(aData, aSize))
            {
                data_.append(static_cast<const char*>(aData), aSize);
            }
            data_length_ += aSize;
        }
        size_t QuicSpdyClientStream::SendRequest(const SpdyHeaderBlock& headers,
                                                 StringPiece body,
                                                 bool fin) {
            bool send_fin_with_headers = fin && body.empty();
            size_t bytes_sent = body.size();
            header_bytes_written_ = WriteHeaders(headers, send_fin_with_headers, nullptr);
            bytes_sent += header_bytes_written_;
            if (!body.empty()) {
                WriteOrBufferData(body, fin, nullptr);
            }
            return bytes_sent;
        }
        void QuicSpdyClientStream::SendBody(const string& data, bool fin) {
            SendBody(data, fin, nullptr);
        }
        void QuicSpdyClientStream::SendBody(const string& data,
                                            bool fin,
                                            QuicAckListenerInterface* listener) {
            WriteOrBufferData(data, fin, listener);
        }
    }  // namespace tools
}  // namespace net
