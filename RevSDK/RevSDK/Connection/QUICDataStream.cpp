//
//  QUICDataStream.cpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/5/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#include "QUICDataStream.h"
#include "RSLog.h"
#include "Utils.hpp"

using namespace rs;

QUICDataStream::QUICDataStream(net::QuicStreamId id, net::tools::QuicClientSession* session):
    QuicSpdyClientStream(id, session),
    mDelegate (nullptr),
    mInitialMS (0),
    mTimeoutMS (20000),
    mFailed (false),
    mHeadersDelivered (false)
{
    mVisitorProxy.setOwner(this);
    set_visitor(&mVisitorProxy);
}

QUICDataStream::~QUICDataStream()
{
    
}

void QUICDataStream::OnStreamFrame(const net::QuicStreamFrame& frame)
{
    QuicSpdyClientStream::OnStreamFrame(frame);
    
    if (!mFailed && mDelegate != nullptr)
    {
        mInitialMS = 0;
    }
}

void QUICDataStream::OnInitialHeadersComplete(bool fin, size_t frame_len)
{
    QuicSpdyClientStream::OnInitialHeadersComplete(fin, frame_len);
    
//    if (!mFailed && mDelegate != nullptr)
//    {
//        mDelegate->onQUICStreamReceivedResponse(this, response_code(), headers());
//    }
}

void QUICDataStream::OnTrailingHeadersComplete(bool fin, size_t frame_len)
{
    QuicSpdyClientStream::OnTrailingHeadersComplete(fin, frame_len);
    
    if (!mFailed && mDelegate != nullptr)
    {
        mDelegate->onQUICStreamReceivedResponse(this, response_code(), headers());
        mInitialMS = 0;
        mHeadersDelivered = true;
        if (!mCache.isEmpty())
        {
            mDelegate->onQUICStreamReceivedData(this, (const char*)mCache.bytes(), mCache.length());
            mCache = Data();
        }
    }
}

void QUICDataStream::onVisitorSentClose()
{
    if (!mFailed && mDelegate != nullptr)
    {
        if (!mHeadersDelivered)
        {
            mDelegate->onQUICStreamReceivedResponse(this, response_code(), headers());
        }
        mDelegate->onQUICStreamReceivedData(this, data().c_str(), data().size());
        mDelegate->onQUICStreamCompleted(this);
        mInitialMS = 0;
    }
}

void QUICDataStream::update(size_t aNowMS)
{
    if (mFailed)
        return;
    
    if (mInitialMS == 0)
    {
        mInitialMS = aNowMS;
        return;
    }
    
    size_t age = aNowMS - mInitialMS;
    
    if (age > mTimeoutMS)
    {
        mFailed = true;
        mError.code = 0;
        mError.domain = "revsdk.quic";
        mError.setDescription("QUIC connection timeout");
        if (mDelegate != nullptr)
            mDelegate->onQUICStreamFailed(this, mError);
    }
}

void QUICDataStream::onSocketError(Error aError)
{
    if (mFailed)
        return;
    
    mFailed = true;
    mError = aError;
    
    Log::warning(kLogTagQUICNetwork, "Socket error %d: %s", (int)aError.code, notNullString(aError.description()));

    if (mDelegate != nullptr)
        mDelegate->onQUICStreamFailed(this, mError);
}
