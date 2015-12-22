//
//  NativeStatsHandler.h
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef NativeStatsHandler_h
#define NativeStatsHandler_h

#include <string>

#include "Utils.hpp"

namespace rs
{
     class Data;
    
     class NativeStatsHandler
     {
        public:
        Data statsData();
        Data locationData();
        Data carrierData();
        Data deviceData();
        Data networkData();
        Data wifiData();
        Data logData();
         
         std::string appName();
     };
}

#endif