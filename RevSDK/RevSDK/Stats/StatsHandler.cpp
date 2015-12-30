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
        
        stringMap["version"] = "1.0";
        stringMap["sdk_version"] = "1.0";
        stringMap["sdk_key"] = "0efbbd35-a131-4419-b330-00de5eb3696b";
        stringMap["app_name"] = mStatsHandler->appName();
        
//        Data wholeData = jsonDataFromDataMap(map, stringMap);
//        return wholeData;
        auto data = mStatsHandler->allData(requestsData.Buffer, stringMap);
        
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
}
