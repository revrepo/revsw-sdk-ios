//
//  StatsHandler.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <map>

#include "StatsHandler.hpp"
#include "NativeStatsHandler.h"
#include "Data.hpp"
#include "DataStorage.hpp"
#include "RequestStatsHandler.hpp"
#include "JSONUtils.hpp"
#include "Utils.hpp"


namespace rs
{
    StatsHandler::StatsHandler()
    {
        mSDKKey              = "";
        mStatsHandler        = std::unique_ptr<NativeStatsHandler>(new NativeStatsHandler);
        mRequestStatsHandler = std::unique_ptr<RequestStatsHandler>(new RequestStatsHandler());
    }
    
    StatsHandler::~StatsHandler()
    {
        //delete mStatsHandler;
        //delete mRequestStatsHandler;
    }
    
    void StatsHandler::setReportingLevel(RSStatsReportingLevel aReportingLevel)
    {
        mStatsReportingLevel = aReportingLevel;
    }
    
    ReportTransactionHanle StatsHandler::createSendTransaction(int aRequestCount)
    {
        ReportTransactionHanle requestsData = mRequestStatsHandler->requestsData(aRequestCount);
        
        std::map<std::string, std::string> stringMap;
        
        stringMap[kAppVersionKey] = mStatsHandler->appVersion();
        stringMap[kSDKVersionKey] = std::to_string(kSDKVersionNumber);
        stringMap[kSDKKeyKey]     = mSDKKey;
        stringMap[kAppNameKey]    = mStatsHandler->appName();
        
        auto data           = mStatsHandler->allData(requestsData.Buffer, stringMap);
        requestsData.Buffer = data;
        
        return requestsData;
    }
    
    bool StatsHandler::hasRequestsData() const
    {
        return mRequestStatsHandler->hasData();
    }
    
    void StatsHandler::addRequestData(const Data& aRequestData)
    {
        mRequestStatsHandler->addNewRequestData(aRequestData);
    }
    
    void StatsHandler::addEvent(const Event& aEvent)
    {
        mStatsHandler->addEvent(aEvent);
    }
    
    void StatsHandler::startMonitoring()
    {
        mStatsHandler->startMonitoring();
    }
    
    void StatsHandler::stopMonitoring()
    {
        mStatsHandler->stopMonitoring();
    }
    
    void StatsHandler::setSDKKey(const std::string& aSDKKey)
    {
        mSDKKey = aSDKKey;
    }
}
