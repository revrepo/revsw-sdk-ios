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
#include "Utils.hpp"
#include "RSLog.h"

using namespace rs;
using namespace net;

static int mQUICConnectionIdCounter = 0;
static std::mutex mQUICConnectionIdLock;

QUICConnection::QUICConnection():
    mDelegate(nullptr),
    mDepth (0),
    mId(0),
    mTS(0)
{
    mQUICConnectionIdLock.lock();
    mId = mQUICConnectionIdCounter++;
    mQUICConnectionIdLock.unlock();
}

QUICConnection::~QUICConnection()
{
    //std::cout << "QUICConnection::~QUICConnection()" << std::endl;
}

void QUICConnection::initialize()
{
    QUICSession::instance();
}

void QUICConnection::startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate)
{
    p_startWithRequest(aRequest, aDelegate, false);
}

void QUICConnection::p_startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate, bool aRedirect)
{
    mRequest.reset(aRequest->clone());
    mAnchor0 = mWeakThis.lock();
    mDelegate = aDelegate;
    mURL = aRequest->URL();
    
    std::string rest = aRequest->rest();
    if (rest.find("//") == 0)
    {
        Log::error(kLogTagQUICRequest, "Path started with double slash:\nurl=%s\nmethod=%s",
                   notNullString(aRequest->URL()),
                   notNullString(aRequest->method()));
    }
    
    if (rest == "/")
    {
        Log::warning(kLogTagQUICRequest, "Empty path:\nurl=%s\nmethod=%s",
                     notNullString(aRequest->URL()),
                     notNullString(aRequest->method()));
        rest = "/";
    }

    SpdyHeaderBlock headers;
    headers[":authority"] = aRequest->host();
    headers[":method"] = aRequest->method();
    headers[":path"] = rest;
    headers[":scheme"] = "https";
    headers["accept"] = "txt/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8";
    headers["accept-language"] = "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4";
    headers["user-agent"] = "Mozilla";
    
    base::StringPiece body(aRequest->body().toString());
    
    for (const auto& i : aRequest->headers())
        headers[i.first] = i.second;
    
    headers["X-Rev-Host"] = aRequest->host();
    headers["X-Rev-Proto"] = aRequest->originalScheme();

    mTS = timestampMS();
    
    std::string dump;
    dump += "timestamp = " + longLongToStr(mTS);
    dump += "url = " + aRequest->URL() + "\n";
    dump += "method = " + aRequest->method() + "\n";
    dump += "body-size = " + intToStr((int)body.size());
    dump += "headers = \n";

    for (const auto& i : headers)
        dump += i.first + ": " + i.second + "\n";
    
    Log::info(kLogTagQUICRequest, "Request #%d\n%s", mId, dump.c_str());

    QUICSession::instance()->sendRequest(headers, body, this, 0, nullptr);
}

void QUICConnection::quicSessionDidReceiveResponse(QUICSession* aSession, net::QuicDataStream* aStream,
                                   const net::SpdyHeaderBlock& aHedaers, int aCode)
{
    std::string dump;
    long long now = timestampMS();
    dump += "timestamp = " + longLongToStr(now);
    dump += "code = " + intToStr(aCode);
    dump += "headers = \n";
    
    for (const auto& i : aHedaers)
        dump += i.first + ": " + i.second + "\n";
    
    
    
    Log::info(kLogTagQUICRequest, "Response #%d in %lld\n%s", mId, (now - mTS), dump.c_str());

    if (mRedirect.get() == nullptr)
    {
        if (aCode == 301 || aCode == 302)
        {
            if (mDepth < 10)
            {
                mAnchor1 = mAnchor0;
                std::shared_ptr<Request> newRequest(mRequest->clone());
                
                net::SpdyHeaderBlock::const_iterator w = aHedaers.find("Location");
                if (w == aHedaers.end())
                {
                    assert(false);
                }
                
                std::string baseURL = mURL;
                std::string url = w->second;
                newRequest->setURL(url);
                std::string host;
                std::string path;
                std::string scheme;
                
                if (decomposeURL(baseURL, url, host, path, scheme))
                {
                    mRedirect.reset(new QUICConnection());
                    mRedirect->p_setRedirectDepth(mDepth + 1);
                    
                    newRequest->setHost(host);
                    newRequest->setPath(path);
                    newRequest->setRest(path);
                    newRequest->setOriginalScheme(scheme);
                    
                    mRedirect->startWithRequest(newRequest, this);
                    return;
                }
            }
            else
            {
                std::cout << "Too many redirects" << std::endl;
                //assert(false);
            }
        }
    }

    if (mDelegate != nullptr)
    {
        net::SpdyHeaderBlock headers;

        for (const auto& h : aHedaers)
        {
            if (h.first.size() == 0)
                continue;
            
            if (h.first[0] != ':')
                headers[h.first] = h.second;
        }
        std::shared_ptr<Response> response = std::make_shared<Response>(mURL, headers, aCode);
        mDelegate->connectionDidReceiveResponse(mWeakThis.lock(), response);
    }
}

void QUICConnection::quicSessionDidReceiveData(QUICSession* aSession, net::QuicDataStream* aStream, const char* aData, size_t aLen)
{
//    if (mParent != nullptr)
//    {
//        mParent->quicSessionDidReceiveData(aSession, aStream, aData, aLen);
//        return;
//    }
    std::string dump;
    dump += "data-len = " + intToStr((int)aLen);
    Log::info(kLogTagQUICRequest, "Data #%d\n%s", mId, dump.c_str());

    if (mRedirect.get() != nullptr)
        return;
    
    if (mDelegate != nullptr)
    {
        Data data(aData, aLen);
        mDelegate->connectionDidReceiveData(mWeakThis.lock(), data);
    }
}

void QUICConnection::quicSessionDidFinish(QUICSession* aSession, net::QuicDataStream* aStream)
{
//    if (mParent != nullptr)
//    {
//        if (aStream == mRedirectedStream)
//        {
//            // ignore
//            return;
//        }
//        mParent->quicSessionDidFinish(aSession, aStream);
//        return;
//    }
    Log::info(kLogTagQUICRequest, "Finished #%d\n", mId);

    if (mRedirect.get() != nullptr)
        return;

    if (mDelegate != nullptr)
    {
        mDelegate->connectionDidFinish(mWeakThis.lock());
    }
    mAnchor0.reset();
}

void QUICConnection::quicSessionDidFail(QUICSession* aSession, net::QuicDataStream* aStream)
{
    Log::info(kLogTagQUICRequest, "Failed #%d\n", mId);
//    if (mParent != nullptr)
//    {
//        if (aStream == mRedirectedStream)
//        {
//            // ignore
//            return;
//        }
//        mParent->quicSessionDidFail(aSession, aStream);
//        return;
//    }
    if (mRedirect.get() != nullptr)
        return;
    
    if (mDelegate != nullptr)
    {
        QUICDataStream* qds = (QUICDataStream*)aStream;
        mDelegate->connectionDidFailWithError(mWeakThis.lock(), qds->error());
    }
    mAnchor0.reset();
}

//void QUICConnection::quicSessionDidCloseStream(QUICSession* aSession,
//                                               net::QuicDataStream* aStream,
//                                               const net::SpdyHeaderBlock& aHeaders,
//                                               const std::string& aData,
//                                               int aCode)
//{
//    net::SpdyHeaderBlock headers;
//    
//    for (const auto& h : aHeaders)
//    {
//        if (h.first.size() == 0)
//            continue;
//        
//        if (h.first[0] != ':')
//            headers[h.first] = h.second;
//    }
//    
//    std::shared_ptr<Response> response = std::make_shared<Response>(mURL, headers, aCode);
//    Data data(aData.c_str(), aData.size());
//    response->setBody(data);
//    
//    if (mDelegate != nullptr)
//    {
//        mDelegate->connectionDidReceiveResponse(mWeakThis.lock(), response);
//        mDelegate->connectionDidReceiveData(mWeakThis.lock(), data);
//        mDelegate->connectionDidFinish(mWeakThis.lock());
//    }
//    
//    mAnchor.reset();
//}

void QUICConnection::quicSessionDidChangeState(QUICSession* aSession, bool aConnected)
{
    
}

std::string QUICConnection::edgeTransport()const
{
    return kQUICProtocolName;
}

void QUICConnection::connectionDidReceiveResponse(std::shared_ptr<Connection> aConnection, std::shared_ptr<Response> aResponse)
{
    mDelegate->connectionDidReceiveResponse(aConnection, aResponse);
}

void QUICConnection::connectionDidReceiveData(std::shared_ptr<Connection> aConnection, Data aData)
{
    mDelegate->connectionDidReceiveData(aConnection, aData);
}

void QUICConnection::connectionDidFinish(std::shared_ptr<Connection> aConnection)
{
    mDelegate->connectionDidFinish(aConnection);
    mAnchor1.reset();
}

void QUICConnection::connectionDidFailWithError(std::shared_ptr<Connection> aConnection, Error aError)
{
    mDelegate->connectionDidFailWithError(aConnection, aError);
    mAnchor1.reset();
}

