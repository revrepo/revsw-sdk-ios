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
    StatsHandler::StatsHandler(std::weak_ptr<DataStorage> aDataStorage)
    {
        mStatsHandler        = std::unique_ptr<NativeStatsHandler>(new NativeStatsHandler);
        mRequestStatsHandler = std::unique_ptr<RequestStatsHandler>(new RequestStatsHandler(aDataStorage));
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
    
    Data StatsHandler::getStatsData()
    {
        const Data requestsData = mRequestStatsHandler->requestsData();
        
        std::map<std::string, std::string> stringMap;
        
        stringMap["version"] = "1.0";
        stringMap["sdk_version"] = "1.0";
        stringMap["sdk_key"] = "0efbbd35-a131-4419-b330-00de5eb3696b";
        stringMap["app_name"] = mStatsHandler->appName();
        
//        Data wholeData = jsonDataFromDataMap(map, stringMap);
//        return wholeData;
        return mStatsHandler->allData(requestsData, stringMap);
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
