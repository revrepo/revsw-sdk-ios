 /*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

#import <Foundation/Foundation.h>

#include "QUICConnection.hpp"
#include "Response.hpp"
#include "Request.hpp"

#include "Model.hpp"
#include "QUICSession.h"
#include "Error.hpp"
#include "Utils.hpp"
#include "RSLog.h"
#include "RSUtils.h"
#include "DebugUsageTracker.hpp"

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
    mEdgeHost = Model::instance()->edgeHost();
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
    if (rest == "//")
    {
        Log::error(kLogTagQUICRequest, "Path is double slash:\nurl=%s\nmethod=%s",
                   notNullString(aRequest->URL()),
                   notNullString(aRequest->method()));
    }
    
    if (rest == "/")
    {
        Log::info(kLogTagQUICRequest, "Empty path:\nurl=%s\nmethod=%s",
                  notNullString(aRequest->URL()),
                  notNullString(aRequest->method()));
        rest = "/";
    }
    
    if (rest.size() == 0)
    {
        rest = "/";
    }
    
    if (rest.size() > 0)
    {
        assert(rest[0] == '/');
    }
    
//    if (rest == "/ibm/main/2/i.gif")
//    {
//        Log::info(kLogTagQUICRequest, "Gotcha");
//    }

    SpdyHeaderBlock headers;
    headers[":authority"] = aRequest->host();
    headers[":method"] = aRequest->method();
    headers[":path"] = rest;
    headers[":scheme"] = "https";
    //headers["accept"] = "txt/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"; // bug
    //headers["accept-language"] = "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,it;q=0.2,th;q=0.2,uk;q=0.2,de;q=0.2,fr;q=0.2"; // bug
    //headers["accept-encoding"] = "gzip";
    //headers["user-agent"] = "Mozilla";
    //headers["user-agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"; // bug
    
    //headers["cache-control"] = "max-age=0";
    //headers["upgrade-insecure-requests"] = "1";
    //headers["x-compress"] = "null";
    
    //Data bData = aRequest->body();
    assert(rest.size() != 0);
    const char* bodyPtr = (const char*)aRequest->body().bytes();
    if (bodyPtr == nullptr)
        bodyPtr = "";
    base::StringPiece body(bodyPtr);//(bData.toString());
    for (const auto& i : aRequest->headers())
        headers[i.first] = i.second;
    
    if (aRequest->host() == mEdgeHost)
    {
        Log::error(kLogTagQUICRequest, "Request host set to %s", notNullString(mEdgeHost));
    }
    
    headers["X-Rev-Host"] = aRequest->host();
    headers["X-Rev-Proto"] = aRequest->originalScheme();

//    mTS = timestampMS();
//    
//    std::string dump;
//    dump += "timestamp = " + longLongToStr(mTS);
//    dump += "url = " + aRequest->URL() + "\n";
//    dump += "method = " + aRequest->method() + "\n";
//    dump += "body-size = " + intToStr((int)body.size());
//    dump += "headers = \n";
//
//    for (const auto& i : headers)
//        dump += i.first + ": " + i.second + "\n";
//    
//    Log::info(kLogTagQUICRequest, "Request #%d\n%s", mId, dump.c_str());
    
    onStart();
    QUICSession::instance()->sendRequest(headers, body, this, 0, nullptr);
}

void QUICConnection::quicSessionDidReceiveResponse(QUICSession* aSession, net::QuicSpdyStream* aStream,
                                   const net::SpdyHeaderBlock& aHeaders, int aCode)
{
    onResponseReceived();
    
//    std::string dump;
//    long long now = timestampMS();
//    dump += "timestamp = " + longLongToStr(now);
//    dump += "code = " + intToStr(aCode);
//    dump += "headers = \n";
//    
//    for (const auto& i : aHeaders)
//        dump += i.first.as_string() + ": " + i.second.as_string() + "\n";
//    
//    Log::info(kLogTagQUICRequest, "Response #%d in %lld\n%s", mId, (now - mTS), dump.c_str());

    if (mRedirect.get() == nullptr)
    {
        if (aCode == 301 || aCode == 302)
        {
            if (mDepth < 10)
            {
                mAnchor1 = mAnchor0;
                std::shared_ptr<Request> newRequest(mRequest->clone());
                
                net::SpdyHeaderBlock::const_iterator w = aHeaders.find("Location");
                if (w == aHeaders.end())
                {
                    assert(false);
                }
                
                std::string baseURL = mURL;
                std::string url = w->second.as_string();
                newRequest->setURL(url);
                std::string host;
                std::string path;
                std::string scheme;
                
                if (decomposeURL(baseURL, url, host, path, scheme))
                {
                    std::shared_ptr<Connection> newConnection = Connection::create<QUICConnection>();
                    mRedirect = std::dynamic_pointer_cast<QUICConnection>(newConnection);
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
        std::map<std::string, std::string> headers;

        for (const auto& h : aHeaders)
        {
            if (h.first.size() == 0)
                continue;
            
            if (h.first[0] != ':')
                headers[h.first.as_string()] = h.second.as_string();
        }
        std::shared_ptr<Response> response = std::make_shared<Response>(mURL, headers, aCode);
        mResponse = response;
        mDelegate->connectionDidReceiveResponse(mWeakThis.lock(), response);
    }
}

void QUICConnection::quicSessionDidReceiveData(QUICSession* aSession, net::QuicSpdyStream* aStream, const char* aData, size_t aLen)
{
//    if (mParent != nullptr)
//    {
//        mParent->quicSessionDidReceiveData(aSession, aStream, aData, aLen);
//        return;
//    }
    
//    std::string dump;
//    dump += "data-len = " + intToStr((int)aLen);
//    Log::info(kLogTagQUICRequest, "Data #%d\n%s", mId, dump.c_str());

    
    addReceivedBytesCount(aLen);
    
    if (mRedirect.get() != nullptr)
        return;
    
    if (mDelegate != nullptr)
    {
        Data data(aData, aLen);
        mDelegate->connectionDidReceiveData(mWeakThis.lock(), data);
    }
}

void QUICConnection::quicSessionDidFinish(QUICSession* aSession, net::QuicSpdyStream* aStream)
{
    onEnd();
    
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
    Model::instance()->debug_usageTracker()->QUICRequestsFinishedWithSuccess();
    Log::info(kLogTagQUICRequest, "Finished #%d\n", mId);

    if (mRedirect.get() != nullptr)
        return;

    if (mDelegate != nullptr)
    {
        if (Model::instance()->shouldCollectRequestsData())
        {
            NSURLRequest* request           = URLRequestFromRequest(mRequest);
            NSHTTPURLResponse* httpResponse = NSHTTPURLResponseFromResponse(mResponse);
            NSString* originalScheme        = NSStringFromStdString(mRequest->originalScheme());
            Data requestData                = dataFromRequestAndResponse(request, httpResponse, mWeakThis.lock().get(), originalScheme, YES);
            Model::instance()->addRequestData(requestData);
        }
        
        mDelegate->connectionDidFinish(mWeakThis.lock());
    }
    mAnchor0.reset();
}

void QUICConnection::quicSessionDidFail(QUICSession* aSession, net::QuicSpdyStream* aStream)
{
    Model::instance()->debug_usageTracker()->QUICRequestsFinishedWithError();
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





