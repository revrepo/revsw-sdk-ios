//
//  QUICConnection.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#pragma once

#include "QUICSessionDelegates.h"

#include <stdio.h>

#include "Connection.hpp"

namespace rs
{
    class QUICConnection : public Connection, public QUICStreamDelegate
    {
    private:
        QUICConnection(const QUICConnection&) {assert(false);}
    public:
        static void initialize();
        QUICConnection();
        ~QUICConnection();
        
        void startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate);
        std::string edgeTransport()const;
        
    private:
        void quicSessionDidReceiveResponse(QUICSession* aSession,
                                           net::QuicDataStream* aStream,
                                           const net::SpdyHeaderBlock& aHedaers,
                                           int aCode);
        void quicSessionDidReceiveData(QUICSession* aSession,
                                       net::QuicDataStream* aStream,
                                       const char* aData, size_t aLen);
        void quicSessionDidFinish(QUICSession* aSession,
                                  net::QuicDataStream* aStream);
        void quicSessionDidFail(QUICSession* aSession,
                                net::QuicDataStream* aStream);
        void quicSessionDidChangeState(QUICSession* aSession, bool aConnected);

        void didReceiveData(void* ) {}
        void didReceiveResponse(void* ) {}
        void didCompleteWithError(void* ) {}
    private:
        std::string mURL;
        ConnectionDelegate* mDelegate;
        std::shared_ptr<Connection> mAnchor;
    };
}

