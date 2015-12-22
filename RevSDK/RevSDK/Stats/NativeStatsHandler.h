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
#include <map>

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
         Data allData(const Data& aRequestsData, const std::map<std::string, std::string>& aParams);
         
         std::string appName();
     };
}

#endif