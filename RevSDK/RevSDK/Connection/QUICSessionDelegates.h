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
        virtual void quicSessionDidReceiveResponse(QUICSession* aSession,
                                                   net::QuicSpdyStream* aStream,
                                                   const net::SpdyHeaderBlock& aHedaers,
                                                   int aCode) = 0;
        virtual void quicSessionDidReceiveData(QUICSession* aSession,
                                               net::QuicSpdyStream* aStream,
                                               const char* aData, size_t aLen) = 0;
        virtual void quicSessionDidFinish(QUICSession* aSession,
                                          net::QuicSpdyStream* aStream) = 0;
        virtual void quicSessionDidFail(QUICSession* aSession,
                                        net::QuicSpdyStream* aStream) = 0;
    };
    
    class QUICSessionDelegate
    {
    public:
        QUICSessionDelegate() {}
        virtual ~QUICSessionDelegate() {}
        virtual void quicSessionDidChangeState(QUICSession* aSession, bool aConnected) = 0;
    };
}
