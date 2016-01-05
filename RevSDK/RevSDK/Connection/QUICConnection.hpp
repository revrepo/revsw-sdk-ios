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
        
        virtual void didReceiveData(void* );
        virtual void didReceiveResponse(void* );
        virtual void didCompleteWithError(void* );
        
    private:
        void quicSessionDidCloseStream(QUICSession* aSession,
                                       net::QuicDataStream* aStream,
                                       const net::SpdyHeaderBlock& aHedaers,
                                       const std::string& aData,
                                       int aCode);
        void quicSessionDidChangeState(QUICSession* aSession, bool aConnected);
    private:
        std::string mURL;
        ConnectionDelegate* mDelegate;
        std::shared_ptr<Connection> mAnchor;
    };
}

