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
#include "LeakDetector.h"

namespace rs
{
    class Data;
    
    struct Configuration
    {
        REV_LEAK_DETECTOR(Configuration);
        
        Configuration() : operationMode(RSOperationModeInner::kRSOperationModeInnerOff)
        {
            //10.02.16 Perepelitsa: assignment defaul values
            abTesMode                      = false;
            abTestingRatio                 = -1;            
            //10.02.16 Perepelitsa: Add new SDK configuration options
            //edge_connectTimeout          = 10;
            //edge_dataReceiveTimeout      = 60;
            //edge_firstByteTimeout        = 60;
            SDKDomain                      = "revsdk.net";
            quicUDPPort                    = 443;
            failuresMonitoringInterval     = 120;
            failuresFailoverThreshold      = 0.6;
            //
        }
        
        Configuration(const Configuration&);
        
        //10.02.16 Perepelitsa: add fields storing condition of a/b testing
        bool abTesMode;
        int abTestingRatio;
        //10.02.16 Perepelitsa: Add new SDK configuration options
        //int edge_connectTimeout;             //sec
        //int edge_dataReceiveTimeout;         //sec
        //int edge_firstByteTimeout;           //sec
        std::string SDKDomain;
        int quicUDPPort;
        int failuresMonitoringInterval; //sec
        double failuresFailoverThreshold;  //(0..1)%
        //
        float sdkReleaseVersion;
        std::string configurationApiURL;
        int refreshInterval;        //Trying to load configuration...
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
        //11.02.16 Perepelitsa: Add support for “internal_domains_black_list” SDK configuration field
        std::vector<std::string> domainsInternalBlackList;
        //
        std::string appName;
        std::string os;
        std::string loggingLevel;
        
        Data toData();
        void print()const;
        
        static Configuration configurationFromData(Data);
    };
}

#endif /* Configuration_hpp */
