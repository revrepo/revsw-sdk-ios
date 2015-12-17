//
//  NativeStatsHandler.h
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef NativeStatsHandler_h
#define NativeStatsHandler_h

#include "Utils.hpp"

namespace rs
{
     class Data;
    
     class NativeStatsHandler
     {
         RSStatsReportingLevel mStatsReportingLevel;
         
        public:
         
         void setStatsReportingLevel(RSStatsReportingLevel);
         
        Data statsData();
     };
}

#endif