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

namespace rs
{
    StatsHandler::StatsHandler()
    {
        mStatsHandler = new NativeStatsHandler;
    }
    
    StatsHandler::~StatsHandler()
    {
        delete mStatsHandler;
    }
    
    void StatsHandler::setReportingLevel(RSStatsReportingLevel aReportingLevel)
    {
        mStatsReportingLevel = aReportingLevel;
    }
    
    Data StatsHandler::getStatsData()
    {
        return mStatsHandler->statsData();
    }
}
