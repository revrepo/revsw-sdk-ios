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
