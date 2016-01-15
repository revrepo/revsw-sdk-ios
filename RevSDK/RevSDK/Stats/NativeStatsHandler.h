/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

#ifndef NativeStatsHandler_h
#define NativeStatsHandler_h

#include <string>
#include <map>

#include "Utils.hpp"

namespace rs
{
     class Data;
     class Event;
    
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
         std::string appVersion();
         
        void addEvent(const Event&);
         
         void startMonitoring();
         void stopMonitoring();
     };
}

#endif