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

namespace rs
{
    class NativeStatsHandler;
    class Data;
    
    class StatsHandler
    {
        NativeStatsHandler* mStatsHandler;
        
        public:
     
        StatsHandler();
        ~StatsHandler();
        
        Data getStatsData();
    };
}

#endif /* StatsHandler_hpp */