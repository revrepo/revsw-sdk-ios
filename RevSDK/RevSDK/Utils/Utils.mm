//
//  Utils.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Utils.hpp"
#include "RSUtils.h"

namespace rs
{
    const float kSDKVersionNumber = kRSSDKVersion;
    
    const std::string kOSKey                           = stdStringFromNSString(kRSOSKey);
    const std::string kAppNameKey                      = stdStringFromNSString(kRSAppNameKey);
    const std::string kSDKReleaseVersionKey            = stdStringFromNSString(kRSSDKReleaseVersionKey);
    const std::string kConfigurationApiURLKey          = stdStringFromNSString(kRSConfigurationApiURLKey);
    const std::string kConfigurationRefreshIntervalKey = stdStringFromNSString(kRSConfigurationRefreshIntervalKey);
    const std::string kConfigurationStaleTimeoutKey    = stdStringFromNSString(kRSConfigurationStaleTimeoutKey);
    const std::string kEdgeHostKey                     = stdStringFromNSString(kRSEdgeHostKey);
    const std::string kOperationModeKey                = stdStringFromNSString(kRSOperationModeKey);
    const std::string kAllowedTransportProtocolsKey    = stdStringFromNSString(kRSAllowedTransportProtocolsKey);
    const std::string kInitialTransportProtocolsKey    = stdStringFromNSString(kRSInitialTransportProtocolsKey);
    const std::string kTransportMonitoringURLKey       = stdStringFromNSString(kRSTransportMonitoringURLKey);
    const std::string kStatsReportingURLKey            = stdStringFromNSString(kRSStatsReportingURLKey);
    const std::string kStatsReportingIntervalKey       = stdStringFromNSString(kRSStatsReportingIntervalKey);
    const std::string kStatsReportingLevelKey          = stdStringFromNSString(kRSStatsReportingLevelKey);
    const std::string kStatsReportingMaxRequestsKey    = stdStringFromNSString(kRSStatsReportingMaxRequestsKey);
    const std::string kDomainsProvisionedListKey       = stdStringFromNSString(kRSDomainsProvisionedListKey);
    const std::string kDomainsWhiteListKey             = stdStringFromNSString(kRSDomainsWhiteListKey);
    const std::string kDomainsBlackListKey             = stdStringFromNSString(kRSDomainsBlackListKey);
    const std::string kConfigsKey                      = "configs";
    const std::string kDeviceStatsKey                  = "stats";
    const std::string kRequestsStatsKey                = "requests";
    const std::string kLoggingLevelKey                 = stdStringFromNSString(kRSLoggingLevelKey);
    
    std::string loadConfigurationURL(const std::string& aSDKKey)
    {
        return _loadConfigurationURL(aSDKKey);
    }
    
    std::string errorDescriptionKey()
    {
        return stdStringFromNSString(NSLocalizedDescriptionKey);
    }
    
    long noErrorCode()
    {
        return kRSNoErrorCode;
    }
    
    std::string httpsProtocolName()
    {
        return kRSHTTPSProtocolName;
    }
    
    std::string quicProtocolName()
    {
        return kRSQUICProtocolName;
    }
    
    bool isValidURL(std::string aURLString)
    {
        return _isValidURL(aURLString);
    }
}
