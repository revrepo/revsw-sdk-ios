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
    const int kSDKVersionNumber = kRSSDKVersion;
    
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
    const std::string kConfigsKey                      = stdStringFromNSString(kRSConfigsKey);
    const std::string kDeviceStatsKey                  = "stats";
    const std::string kRequestsStatsKey                = "requests";
    const std::string kLoggingLevelKey                 = stdStringFromNSString(kRSLoggingLevelKey);
    
    const std::string kHTTPSProtocolName    = stdStringFromNSString(kRSHTTPSProtocolName);
    const std::string kStandardProtocolName = stdStringFromNSString(kRSStandardProtocolName);
    const std::string kQUICProtocolName     = stdStringFromNSString(kRSQUICProtocolName);
    
    const std::string kLogLevelNone  = stdStringFromNSString(kRSLogLevelNone);
    const std::string kLogLevelDebug = stdStringFromNSString(kRSLogLevelDebug);
    const std::string kLogLevelError = stdStringFromNSString(kRSLogLevelError);
    const std::string kLogLevelInfo  = stdStringFromNSString(kRSLogLevelInfo);
    
    const std::string kOperationModeOffString            = stdStringFromNSString(kRSOperationModeOffString);
    const std::string kOperationModeTransferString       = stdStringFromNSString(kRSOperationModeTransferString);
    const std::string kOperationModeReportString         = stdStringFromNSString(kRSOperationModeReportString);
    const std::string kOperationModeTransferReportString = stdStringFromNSString(kRSOperationModeTransferReportString);
    
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
        return kHTTPSProtocolName;
    }
    
    std::string quicProtocolName()
    {
        return kQUICProtocolName;
    }
    
    bool isValidURL(const std::string& aURLString)
    {
        NSString* urlNSString = NSStringFromStdString(aURLString);
        return _isValidURL(urlNSString);
    }
    
    bool isValidConfiguration(const Data& aConfigurationData, Error* aError)
    {
        return _isValidConfiguration(aConfigurationData, aError);
    }
}
