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
    StatsHandler::StatsHandler(DataStorage* aDataStorage)
    {
        mStatsHandler        = new NativeStatsHandler;
        mRequestStatsHandler = new RequestStatsHandler(aDataStorage);
    }
    
    StatsHandler::~StatsHandler()
    {
        delete mStatsHandler;
        delete mRequestStatsHandler;
    }
    
    void StatsHandler::setReportingLevel(RSStatsReportingLevel aReportingLevel)
    {
        mStatsReportingLevel = aReportingLevel;
    }
    
    Data StatsHandler::getStatsData()
    {
        std::map<std:: string, Data> map;
        
        const Data statsData    = mStatsHandler->statsData();
        const Data requestsData = mRequestStatsHandler->requestsData();
        map[kDeviceStatsKey]    = statsData;
        map[kRequestsStatsKey]  = requestsData;
        
        Data wholeData = jsonDataFromDataMap(map);
        return wholeData;
    }
    
    void StatsHandler::addRequestData(const Data& aRequestData)
    {
        mRequestStatsHandler->addNewRequestData(aRequestData);
    }
    
    void StatsHandler::deleteRequestsData()
    {
        mRequestStatsHandler->deleteRequestsData();
    }
}
