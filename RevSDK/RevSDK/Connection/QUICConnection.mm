//
//  QUICConnection.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "QUICConnection.hpp"
#include "Response.hpp"
#include "Request.hpp"

#include "QUICSession.h"
#include "Error.hpp"
#include "RSUTils.h"

using namespace rs;
using namespace net;

QUICConnection::QUICConnection():
    mDelegate (nullptr)
{
}

QUICConnection::~QUICConnection()
{
}

void QUICConnection::initialize()
{
    QUICSession::instance();
}

void QUICConnection::startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate)
{
    mAnchor = mWeakThis.lock();
    mDelegate = aDelegate;
    mURL = aRequest->URL();

    SpdyHeaderBlock headers;
    headers[":authority"] = aRequest->host();
    headers[":method"] = aRequest->method();
    headers[":path"] = aRequest->rest();
    headers[":scheme"] = "https";
    headers["accept"] = "txt/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8";
    headers["accept-language"] = "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4";
    headers["user-agent"] = "Mozilla";
    
    base::StringPiece body(aRequest->body().toString());
    
    for (const auto& i : aRequest->headers())
        headers[i.first] = i.second;
    
    QUICSession::instance()->sendRequest(headers, body, this);
//        {
//            Error error;
//            error.code = 0;
//            error.domain = "revsdk";
//            error.userInfo["description"] = "QUIC connection not established";
//            return;
//        }
}

void QUICConnection::quicSessionDidCloseStream(QUICSession* aSession,
                                               net::QuicDataStream* aStream,
                                               const net::SpdyHeaderBlock& aHeaders,
                                               const std::string& aData,
                                               int aCode)
{
    net::SpdyHeaderBlock headers;
    
    for (const auto& h : aHeaders)
    {
        if (h.first.size() == 0)
            continue;
        
        if (h.first[0] != ':')
            headers[h.first] = h.second;
    }
    
    std::shared_ptr<Response> response = std::make_shared<Response>(mURL, headers, aCode);
    Data data(aData.c_str(), aData.size());
    response->setBody(data);
    
    if (mDelegate != nullptr)
    {
        mDelegate->connectionDidReceiveResponse(mWeakThis.lock(), response);
        mDelegate->connectionDidReceiveData(mWeakThis.lock(), data);
        mDelegate->connectionDidFinish(mWeakThis.lock());
    }
    
    mAnchor.reset();
}

void QUICConnection::quicSessionDidChangeState(QUICSession* aSession, bool aConnected)
{
    
}

std::string QUICConnection::edgeTransport()const
{
    return kRSQUICProtocolName;
}
