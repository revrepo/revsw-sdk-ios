//
//  QUICClientSession.cpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/5/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

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

QUICDataStream* QUICClientSession::rsCreateOutgoingDynamicStream(SpdyPriority priority)
{
    if (!crypto_stream_->encryption_established()) {
        DVLOG(1) << "Encryption not active so no outgoing stream created.";
        return nullptr;
    }
    if (GetNumOpenOutgoingStreams() >= get_max_open_streams()) {
        DVLOG(1) << "Failed to create a new outgoing stream. "
        << "Already " << GetNumOpenOutgoingStreams() << " open.";
        return nullptr;
    }
    if (goaway_received() && respect_goaway_) {
        DVLOG(1) << "Failed to create a new outgoing stream. "
        << "Already received goaway.";
        return nullptr;
    }
    QUICDataStream* stream = rsCreateClientStream();
    stream->SetPriority(priority);
    ActivateStream(stream);
    return stream;
}

QUICDataStream* QUICClientSession::rsCreateClientStream()
{
    return new QUICDataStream(this->GetNextOutgoingStreamId(), this);
}
