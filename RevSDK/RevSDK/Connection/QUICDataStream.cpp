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
    
//    mCache = mCache.byAppendingData(Data(<#const void *aBytes#>, <#size_t aLength#>))
    
    if (!mFailed && mDelegate != nullptr)
    {
        mInitialMS = 0;
    }
}

void QUICDataStream::OnInitialHeadersComplete(bool fin, size_t frame_len)
{
    QuicSpdyClientStream::OnInitialHeadersComplete(fin, frame_len);
    if (!mFailed && mDelegate != nullptr)
    {
        mDelegate->onQUICStreamReceivedResponse(this, response_code(), headers());
        mInitialMS = 0;
        mHeadersDelivered = true;
    }
//    if (!mFailed && mDelegate != nullptr)
//    {
//        mDelegate->onQUICStreamReceivedResponse(this, response_code(), headers());
//    }
}

void QUICDataStream::OnTrailingHeadersComplete(bool fin, size_t frame_len)
{
    QuicSpdyClientStream::OnTrailingHeadersComplete(fin, frame_len);
    
//        if (!mCache.isEmpty())
//        {
//            mDelegate->onQUICStreamReceivedData(this, (const char*)mCache.bytes(), mCache.length());
//            mCache = Data();
//        }
}

void QUICDataStream::onVisitorSentClose()
{
    if (!mFailed && mDelegate != nullptr)
    {
        if (!mHeadersDelivered)
        {
            mDelegate->onQUICStreamReceivedResponse(this, response_code(), headers());
            mHeadersDelivered = true;
        }
        should_add_incoming_data(0, 0);
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

bool QUICDataStream::should_add_incoming_data(const void* aData, size_t aSize)
{
    if (mHeadersDelivered)
    {
        if (mDelegate)
        {
            if (mCacheList.size() > 0)
            {
                for (const Data& d : mCacheList)
                    mDelegate->onQUICStreamReceivedData(this, (const char*)d.bytes(), d.length());
                mCacheList.clear();
            }
            if (aData != nullptr && aSize > 0)
                mDelegate->onQUICStreamReceivedData(this, (const char*)aData, aSize);
        }
    }
    else
    {
        if (aData != nullptr && aSize > 0)
            mCacheList.push_back(Data(aData, aSize));
    }
    
    return false;
}
