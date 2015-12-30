//
//  Utils.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Utils_hpp
#define Utils_hpp

#include <stdio.h>
#include <string>

namespace rs
{
    
typedef enum
{
   kRSLogginLevelNone = 0,
   kRSLoggingLevelError = 1,
   kRSLoggingLevelDebug = 2,
   kRSLogginLevelInfo  = 3
    
}RSLogginLevel;

typedef enum
{
    kRSOperationModeInnerOff = 0,
    kRSOperationModeInnerTransport = 1,
    kRSOperationModeInnerReport = 2,
    kRSOperationModeInnerTransportAndReport = 3
}RSOperationModeInner;

typedef enum
{
    kRSStatsReportingLevelDebug,
    kRSStatsReportingLevelRelease
    
}RSStatsReportingLevel;
    
    extern const float kSDKVersionNumber;
    
    extern const std::string kOSKey;
    extern const std::string kAppNameKey;
    extern const std::string kSDKReleaseVersionKey;
    extern const std::string kConfigurationApiURLKey;
    extern const std::string kConfigurationRefreshIntervalKey;
    extern const std::string kConfigurationStaleTimeoutKey;
    extern const std::string kEdgeHostKey;
    extern const std::string kOperationModeKey;
    extern const std::string kAllowedTransportProtocolsKey;
    extern const std::string kInitialTransportProtocolsKey;
    extern const std::string kTransportMonitoringURLKey;
    extern const std::string kStatsReportingURLKey;
    extern const std::string kStatsReportingIntervalKey;
    extern const std::string kStatsReportingLevelKey;
    extern const std::string kStatsReportingMaxRequestsKey;
    extern const std::string kDomainsProvisionedListKey;
    extern const std::string kDomainsWhiteListKey;
    extern const std::string kDomainsBlackListKey;
    extern const std::string kConfigsKey;
    extern const std::string kDeviceStatsKey;
    extern const std::string kRequestsStatsKey;
    extern const std::string kLoggingLevelKey;
    
    std::string loadConfigurationURL(const std::string&);
    std::string reportStatsURL();
    std::string errorDescriptionKey();
    long noErrorCode();
    std::string httpsProtocolName();
    std::string quicProtocolName();
    
    bool isValidURL(std::string);
}

#endif /* Utils_hpp */
