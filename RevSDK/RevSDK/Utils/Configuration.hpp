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
        std::string operationMode;
        std::vector<std::string> allowedProtocols;
        std::string initialTransportProtocol;
        std::string transportMonitoringURL;
        std::string statsReportingURL;
        int statsReportingInterval;
        std::string statsReportingLevel;
        int statsReportingMaxRequests;
        std::vector<std::string> domainsProvisionedList;
        std::vector<std::string> domainsWhiteList;
        std::vector<std::string> domainsBlackList;
        
        std::string appName;
        std::string os;
        
        Data toData();
        void print()const;
        
        static Configuration configurationFromData(Data);
    };
}

#endif /* Configuration_hpp */
