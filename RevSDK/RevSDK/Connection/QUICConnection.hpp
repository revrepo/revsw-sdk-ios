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
#include <map>
#include <mutex>

#include "Connection.hpp"

namespace rs
{
    class QUICDataStream;
    class QUICConnection : public Connection, public QUICStreamDelegate, public ConnectionDelegate
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
        void p_setRedirectDepth(int aDepth) { mDepth = aDepth; }
        void p_startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate, bool aRedirect);
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
        
        void connectionDidReceiveResponse(std::shared_ptr<Connection> aConnection, std::shared_ptr<Response> aResponse);
        void connectionDidReceiveData(std::shared_ptr<Connection> aConnection, Data aData);
        void connectionDidFinish(std::shared_ptr<Connection> aConnection);
        void connectionDidFailWithError(std::shared_ptr<Connection> aConnection, Error aError);

    private:
        int mId;
        long long mTS;
        std::string mURL;
        ConnectionDelegate* mDelegate;
        std::shared_ptr<Connection> mAnchor0;
        std::shared_ptr<Connection> mAnchor1;
        std::shared_ptr<Request> mRequest;
        std::shared_ptr<Response> mResponse;
        std::shared_ptr<QUICConnection> mRedirect;
        int mDepth;
    };
}

