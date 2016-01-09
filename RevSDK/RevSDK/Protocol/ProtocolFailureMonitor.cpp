//
//  ProtocolFailureMonitor.cpp
//  RevSDK
//
//  Created by Vlad Joss on 09.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//
#include <assert.h>

#include "RSLog.h"

#include "ProtocolFailureMonitor.h"

using namespace rs;

std::mutex ProtocolFailureMonitor::mLock;
ProtocolFailureMonitor* ProtocolFailureMonitor::mInstanse = nullptr;

void ProtocolFailureMonitor::initialize()
{
    static std::mutex initLock;
    
    std::lock_guard<std::mutex> scopedLock(initLock);
    mInstanse = new ProtocolFailureMonitor();
    
    mInstanse->mReportMap[standardProtocolName()]   = std::vector<ErrorReport>();
    mInstanse->mReportMap[quicProtocolName()]       = std::vector<ErrorReport>();
    
    mInstanse->mReportMap[standardProtocolName()].reserve(256);
    mInstanse->mReportMap[quicProtocolName()].reserve(256);
}

ProtocolFailureMonitor* ProtocolFailureMonitor::getInstance()
{
    assert(mInstanse);
    return mInstanse;
} 

void ProtocolFailureMonitor::logFailure(const std::string& aProtocolID, long aErrorCode)
{
    std::lock_guard<std::mutex> scopedLock(mLock);
    
    mInstanse->mReportMap[aProtocolID].push_back(ErrorReport(aErrorCode));
    mInstanse->validate(aProtocolID);
}

void ProtocolFailureMonitor::validate(const std::string& aProtocolID)
{
    typedef std::chrono::seconds tSec;
    typedef std::chrono::system_clock tSclock;
    
    auto& vec = mInstanse->mReportMap[aProtocolID];
    auto& rqVec = mInstanse->mLoggedConnections[aProtocolID];
    
    //// clear old requests
    {
        auto rqIter = rqVec.begin();
        
        int64_t timePassed = std::chrono::duration_cast<tSec>(std::chrono::system_clock::now() - *rqIter).count();
        
        while (timePassed > mInstanse->kTimeoutSec)
        {
            rqIter = rqVec.erase(rqIter);
            if (rqIter != rqVec.end())
            {
                timePassed = std::chrono::duration_cast<tSec>(std::chrono::system_clock::now() - *rqIter).count();
            }
        }
    }
    //// clear old fails
    {
        auto iter = vec.begin();
        
        int64_t timePassed = std::chrono::duration_cast<tSec>(std::chrono::system_clock::now() - iter->DateReported).count();
        
        while (timePassed > mInstanse->kTimeoutSec)
        {
            iter = vec.erase(iter);
            if (iter != vec.end())
            {
                timePassed = std::chrono::duration_cast<tSec>(std::chrono::system_clock::now() - iter->DateReported).count();
            }
        }
    }
    assert(vec.size() <= rqVec.size());
    
    double failPercent = vec.size() / ((float)rqVec.size());
#if RS_LOG
    std::string message(aProtocolID + " | Request failed (" + std::to_string(vec.front().Code)+ "); percent of failed requests in last ");
    
    message += std::to_string(kTimeoutSec);
    
    message += " sec :: ";
    
    message += std::to_string((int)(failPercent * 100));
    
    Log::warning(kRSLogKey_ProtocolAvailability, message.c_str());
#endif
    
    if (failPercent > mInstanse->kMinFailPercentToSwitchProto)
    {
        Log::error(kRSLogKey_ProtocolAvailability, "Too many failed requests using current protocol, trying to switch.");
        for (auto it: cbOnProtocolFailed)
        {
            it.second(aProtocolID);
        }
    }
}

void ProtocolFailureMonitor::logConnection(const std::string &aProtocolID)
{
    std::lock_guard<std::mutex> scopedLock(mLock);
    
    mInstanse->mLoggedConnections[aProtocolID].push_back(std::chrono::system_clock::now());
}

void ProtocolFailureMonitor::clear()
{
    mInstanse->mReportMap[standardProtocolName()].clear();
    mInstanse->mReportMap[quicProtocolName()].clear();
}

void ProtocolFailureMonitor::subscribeOnProtocolFailed(size_t aID, std::function<void(const std::string&)> fCallback)
{
    std::lock_guard<std::mutex> scopedLock(mLock);
    
    mInstanse->cbOnProtocolFailed[aID] = fCallback;
}

void ProtocolFailureMonitor::unsubscribe(size_t aID)
{
    std::lock_guard<std::mutex> scopedLock(mLock);
    auto iter = mInstanse->cbOnProtocolFailed.find(aID);
    
    if (mInstanse->cbOnProtocolFailed.end() != iter)
    {
        mInstanse->cbOnProtocolFailed.erase(iter);
    }
}






























