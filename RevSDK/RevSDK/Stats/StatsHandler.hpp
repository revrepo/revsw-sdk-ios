//
//  StatsHandler.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef StatsHandler_hpp
#define StatsHandler_hpp

#include <stdio.h>

#include "Utils.hpp"

namespace rs
{
    class NativeStatsHandler;
    class Data;
    class DataStorage;
    class RequestStatsHandler;
    
    class StatsHandler
    {
        RequestStatsHandler* mRequestStatsHandler;
        NativeStatsHandler* mStatsHandler;
        
        RSStatsReportingLevel mStatsReportingLevel;
        
        public:
     
        StatsHandler(DataStorage*);
        ~StatsHandler();
        
        void setReportingLevel(RSStatsReportingLevel);
        
        Data getStatsData();
        void addRequestData(const Data&);
        void deleteRequestsData();
    };
}

#endif /* StatsHandler_hpp */
