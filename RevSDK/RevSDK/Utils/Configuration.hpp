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

namespace rs
{
    class Data;
    
    struct Configuration
    {
        Configuration(){}
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
        
        Data toData();
        void print()const;
        
        static Configuration configurationFromData(Data);
        
        bool isValid();
    };
}

#endif /* Configuration_hpp */
