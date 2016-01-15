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

#include "RSUDPService.h"
#include <assert.h>
#include <boost/date_time/posix_time/posix_time_types.hpp>
#include "RSLog.h"

using namespace rs;

boost::posix_time::ptime beginning()
{
    static boost::posix_time::ptime t;
    static bool f = false;
    
    if (!f)
    {
        f = true;
        t = boost::posix_time::microsec_clock::universal_time();
    }
    
    return t;
}

static int gUDPServiceCounter = 0;

UDPService::UDPService(const Info& aInfo):
    mHost(aInfo.host),
    mPort(aInfo.port),
    mSocket(nullptr),
    mHandler(aInfo.handler),
    mThread(aInfo.thread),
    mFirstConnect(false),
    mCloseFlag (false),
    mId (gUDPServiceCounter++)
{
    mBuffer.resize(65536);
    mBuffer.shrink_to_fit();
    mThreadId = pthread_self();
}

UDPService::~UDPService()
{
    
}

void UDPService::dispatch(const std::string& aHost, int aPort, std::function<void(UDPService*)> aHandler)
{
    beginning();

    Info* info = new Info();
    info->host = aHost;
    info->port = aPort;
    info->handler = aHandler;
    info->thread = new std::thread(&UDPService::threadFunc, info);
    info->thread->detach();
}

void UDPService::threadFunc(void* t)
{
    Info* info = (Info*)t;
    if (info == nullptr)
        return;
    
    UDPService* service = new UDPService(*info);
    delete info;

    service->run();
    
    delete service;
}

void UDPService::run()
{
    while (!mCloseFlag)
    {
        if (mSocket == nullptr)
            mSocket = new UDPSocket(mHost, mPort);
        
        if (!mSocket->valid())
        {
            delete mSocket;
            std::this_thread::sleep_for(std::chrono::milliseconds(1000));
            mSocket = new UDPSocket(mHost, mPort);
            Log::warning(kLogTagQUICNetwork, "UDPService recreated socket");
        }
        
        if (!mSocket->connected())
            mSocket->connect();
        
        if (!mFirstConnect)
        {
            if (mHandler)
                mHandler(this);
            mFirstConnect = true;
        }
        
        bool isTimeout = false;
        Error error;
        size_t len = mSocket->recv(&mBuffer[0], mBuffer.size(), 1, isTimeout, error);
        if (!isTimeout && len > 0)
        {
            if (mOnRecv)
                mOnRecv(this, &mBuffer[0], len);
        }
        if (!error.isNoError())
        {
            if (mOnError)
                mOnError(this, error.code, error.description());
        }
        
        mQueueLock.lock();
        Data::List queue = mQueue;
        mQueue.clear();
        mQueueLock.unlock();

        for (Data& data : queue)
            mSocket->send(data.bytes(), data.length());
        
        mCallsLock.lock();
        FuncList calls = mCalls;
        mCalls.clear();
        mCallsLock.unlock();
        
        for (std::function<void(void)> call : calls)
            if (call)
                call();
        
        boost::posix_time::ptime now = boost::posix_time::microsec_clock::universal_time();
        boost::posix_time::time_duration diff = now - beginning();
        if (mOnIdle)
            mOnIdle((size_t)diff.total_milliseconds());
    }
    
    mSocket->close();
}

bool UDPService::send(const void* aData, size_t aSize, bool* aSync)
{
    if (aData == nullptr || aSize == 0)
        return false;
    
    if (p_properThread())
    {
        bool ok = mSocket->send(aData, aSize);
        if (aSync != nullptr)
            *aSync = true;
        return ok;
    }
    
    Data data(aData, aSize);
    
    mQueueLock.lock();
    mQueue.push_back(data);
    mQueueLock.unlock();
    
    if (aSync != nullptr)
        *aSync = false;
    
    return false;
}

void UDPService::perform(std::function<void(void)> aFunc, bool aForceAsync)
{
    if (!aFunc)
        return;
    
    if (p_properThread() && aForceAsync)
    {
        aFunc();
        return;
    }
    
    mCallsLock.lock();
    mCalls.push_back(aFunc);
    mCallsLock.unlock();
}

bool UDPService::connected() const
{
    assert(p_properThread());
    
    return mSocket->connected();
}

void UDPService::shutdown()
{
    mCloseFlag = true;
}

bool UDPService::p_properThread() const
{
    return pthread_self() == mThreadId;
}