//
//  Configuration.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Configuration_hpp
#define Configuration_hpp

#include <stdio.h>
#include <vector>
#include <string>

#import "Utils.hpp"
#include "LeakDetector.h"

namespace rs
{
    class Data;
    
    struct Configuration
    {
        REV_LEAK_DETECTOR(Configuration);
        
        Configuration() : operationMode(RSOperationModeInner::kRSOperationModeInnerOff)
        {}
        
        Configuration(const Configuration&);
        
        float sdkReleaseVersion;
        std::string configurationApiURL;
        int refreshInterval;
        int staleTimeout;
        std::string edgeHost;
        RSOperationModeInner operationMode;
        std::vector<std::string> allowedProtocols;
        std::string initialTransportProtocol;
        std::string transportMonitoringURL;
        std::string statsReportingURL;
        int statsReportingInterval;
        RSStatsReportingLevel statsReportingLevel;
        int statsReportingMaxRequests;
        std::vector<std::string> domainsProvisionedList;
        std::vector<std::string> domainsWhiteList;
        std::vector<std::string> domainsBlackList;
        
        std::string appName;
        std::string os;
        std::string loggingLevel;
        
        Data toData();
        void print()const;
        
        static Configuration configurationFromData(Data);
    };
}

#endif /* Configuration_hpp */
