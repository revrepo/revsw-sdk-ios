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

uint32 QUICDataStream::ProcessData(const char* data, uint32 data_len)
{
    uint32 result = QuicSpdyClientStream::ProcessData(data, data_len);

    if (!mFailed && mDelegate != nullptr)
    {
//        if (mHeadersDelivered)
//        {
//            mDelegate->onQUICStreamReceivedData(this, data, data_len);
//        }
//        else
//        {
//            mCache = mCache.byAppendingData((const void*)data, data_len);
//        }
        mInitialMS = 0;
    }
    
    return result;
}

void QUICDataStream::OnStreamHeadersComplete(bool fin, size_t frame_len)
{
    QuicSpdyClientStream::OnStreamHeadersComplete(fin, frame_len);
    
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
