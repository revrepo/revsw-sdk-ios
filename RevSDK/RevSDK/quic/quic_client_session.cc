// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "quic_client_session.h"
#include "base/logging.h"
#include "net/quic/crypto/crypto_protocol.h"
#include "net/quic/crypto/proof_verifier.h"
#include "net/quic/quic_server_id.h"
#include "net/quic/quic_crypto_client_stream.h"
#include "RevProofVerifier.h"

using std::string;

namespace net
{
    namespace tools
    {
        QuicClientSession::QuicClientSession(const QuicConfig& config,
                                             QuicConnection* connection,
                                             const QuicServerId& server_id,
                                             QuicCryptoClientConfig* crypto_config) :
        QuicClientSessionBase(connection, config),
        crypto_stream_(new QuicCryptoClientStream(server_id,
                                                  this,
                                                  new RevProofVerifyContext(),
                                                  crypto_config)),
        respect_goaway_(true)
        {
        }
        
        QuicClientSession::~QuicClientSession()
        {
        }
        
        void QuicClientSession::OnProofValid(const QuicCryptoClientConfig::CachedState& /*cached*/) {}
        
        void QuicClientSession::OnProofVerifyDetailsAvailable(const ProofVerifyDetails& /*verify_details*/) {}
        
        bool QuicClientSession::EncryptionEstablished() const
        {
            return crypto_stream_->encryption_established();
        }

        QuicSpdyClientStream* QuicClientSession::CreateOutgoingDynamicStream()
        {
            if (!crypto_stream_->encryption_established()) {
                DVLOG(1) << "Encryption not active so no outgoing stream created.";
                return nullptr;
            }
            if (GetNumOpenStreams() >= get_max_open_streams()) {
                DVLOG(1) << "Failed to create a new outgoing stream. "
                << "Already " << GetNumOpenStreams() << " open.";
                return nullptr;
            }
            if (goaway_received() && respect_goaway_) {
                DVLOG(1) << "Failed to create a new outgoing stream. "
                << "Already received goaway.";
                return nullptr;
            }
            QuicSpdyClientStream* stream = CreateClientStream();
            ActivateStream(stream);
            return stream;
        }
        
        QuicSpdyClientStream* QuicClientSession::CreateClientStream()
        {
            return new QuicSpdyClientStream(this->GetNextStreamId(), this);
        }
        
        QuicCryptoClientStream* QuicClientSession::GetCryptoStream()
        {
            return crypto_stream_.get();
        }
        
        void QuicClientSession::CryptoConnect()
        {
            DCHECK(flow_controller());
            crypto_stream_->CryptoConnect();
        }
        
        int QuicClientSession::GetNumSentClientHellos() const
        {
            return crypto_stream_->num_sent_client_hellos();
        }
        
        QuicDataStream* QuicClientSession::CreateIncomingDynamicStream(QuicStreamId id)
        {
            DLOG(ERROR) << "Server push not supported";
            return nullptr;
        }
    }  // namespace tools
}  // namespace net