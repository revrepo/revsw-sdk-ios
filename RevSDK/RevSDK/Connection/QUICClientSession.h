//
//  QUICClientSession.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/5/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#pragma once

#include "QUICHeaders.h"
#include "QUICDataStream.h"

namespace rs
{
    class QUICClientSession: public net::tools::QuicClientSession
    {
    public:
        QUICClientSession(const net::QuicConfig &config,
                          net::QuicConnection *connection,
                          const net::QuicServerId &server_id,
                          net::QuicCryptoClientConfig *crypto_config);
        
        ~QUICClientSession() override;
        
        QUICDataStream* rsCreateOutgoingDynamicStream();
        QUICDataStream* rsCreateClientStream();

    };
}
