//
//  QUICSessionDelegates.h
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#pragma once

#include "QUICHeaders.h"

namespace rs
{
    class QUICSession;
    
    class QUICStreamDelegate
    {
    public:
        QUICStreamDelegate() {}
        virtual ~QUICStreamDelegate() {}
        virtual void quicSessionDidCloseStream(QUICSession* aSession,
                                               net::QuicDataStream* aStream,
                                               const net::SpdyHeaderBlock& aHedaers,
                                               const std::string& aData,
                                               int aCode) = 0;
    };
    
    class QUICSessionDelegate
    {
    public:
        QUICSessionDelegate() {}
        virtual ~QUICSessionDelegate() {}
        virtual void quicSessionDidChangeState(QUICSession* aSession, bool aConnected) = 0;
    };
}
