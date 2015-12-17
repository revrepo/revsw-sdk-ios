//
//  StatsHandler.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "StatsHandler.hpp"
#include "NativeStatsHandler.h"
#include "Data.hpp"
#include "DataStorage.hpp"
#include "RequestStatsHandler.hpp"

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
        return mStatsHandler->statsData();
    }
    
    void StatsHandler::addRequestData(const Data& aRequestData)
    {
        mRequestStatsHandler->addNewRequestData(aRequestData);
    }
}
