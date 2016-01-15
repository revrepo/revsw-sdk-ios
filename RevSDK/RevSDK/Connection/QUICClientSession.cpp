/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

#include "QUICClientSession.h"

using namespace rs;
using namespace net;
using namespace net::tools;

QUICClientSession::QUICClientSession(const net::QuicConfig &config,
                  net::QuicConnection *connection,
                  const net::QuicServerId &server_id,
                  net::QuicCryptoClientConfig *crypto_config):
    QuicClientSession(config, connection, server_id, crypto_config)
{
    
}

QUICClientSession::~QUICClientSession()
{
    
}

QUICDataStream* QUICClientSession::rsCreateOutgoingDynamicStream()
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
    QUICDataStream* stream = rsCreateClientStream();
    ActivateStream(stream);
    return stream;
}

QUICDataStream* QUICClientSession::rsCreateClientStream()
{
    return new QUICDataStream(this->GetNextStreamId(), this);
}
