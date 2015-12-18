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
        const Data networkData  = mStatsHandler->networkData();
        const Data wifiData     = mStatsHandler->wifiData();
        const Data carrierData  = mStatsHandler->carrierData();
        const Data deviceData   = mStatsHandler->deviceData();
        const Data locationData = mStatsHandler->locationData();
        const Data logData      = mStatsHandler->logData();
        
        map[kRequestsStatsKey]  = requestsData;
        map["network"] = networkData;
        map["device"] = deviceData;
        map["carrier"] = carrierData;
        map["wifi"] = wifiData;
        map["location"] = locationData;
        map["log_events"] = logData;
        
        std::map<std::string, std::string> stringMap;
        
        stringMap["version"] = "1.0";
        stringMap["sdk_version"] = "1.0";
        stringMap["sdk_key"] = "0efbbd35-a131-4419-b330-00de5eb3696b";
        stringMap["app_name"] = mStatsHandler->appName();
        
        Data wholeData = jsonDataFromDataMap(map, stringMap);
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
