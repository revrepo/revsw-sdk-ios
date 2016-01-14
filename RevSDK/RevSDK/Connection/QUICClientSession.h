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
#include "LeakDetector.h"

namespace rs
{
    class QUICClientSession: public net::tools::QuicClientSession
    {
        REV_LEAK_DETECTOR(QUICClientSession);
        
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
