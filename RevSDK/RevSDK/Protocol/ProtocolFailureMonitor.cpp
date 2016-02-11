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

#include <assert.h>

#include "RSLog.h"

#include "ProtocolFailureMonitor.h"

//11.02.16 Perepelitsa: use Model configuration
#include "Model.hpp"
//

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
    
    std::vector<ErrorReport> vec;
    std::vector<tTimepoint> rqVec;
    
    {
        std::lock_guard<std::mutex> guard(mLock);
        vec   = mInstanse->mReportMap[aProtocolID];
        rqVec = mInstanse->mLoggedConnections[aProtocolID];
    }
    
    //// clear old requests
    {
        auto rqIter = rqVec.begin();
        
        int64_t timePassed = std::chrono::duration_cast<tSec>(std::chrono::system_clock::now() - *rqIter).count();
        //11.02.16 Perepelitsa: remove kTimeoutSec constant
        //while (timePassed > mInstanse->kTimeoutSec)
        while (timePassed > Model::instance()->failuresMonitoringInterval())
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
        
        //11.02.16 Perepelitsa: remove kTimeoutSec constant
        //while (timePassed > mInstanse->kTimeoutSec)
        while (timePassed > Model::instance()->failuresMonitoringInterval())
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
    
    //11.02.16 Perepelitsa: remove kTimeoutSec constant
    //message += std::to_string(kTimeoutSec);
    message += std::to_string(Model::instance()->failuresMonitoringInterval());
    
    message += " sec :: ";
    
    message += std::to_string((int)(failPercent * 100));
    
    Log::warning(kLogTagProtocolAvailability, message.c_str());
#endif
    //11.02.16 Perepelitsa: remove kMinFailPercentToSwitchProto constant
    //if (failPercent > mInstanse->kMinFailPercentToSwitchProto)
    if (failPercent > Model::instance()->failuresFailoverThreshold())
    {
        Log::error(kLogTagProtocolAvailability, "Too many failed requests using current protocol, trying to switch.");
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
    Log::warning(kLogTagProtocolAvailability, "Clearing requests failure records.");
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






























