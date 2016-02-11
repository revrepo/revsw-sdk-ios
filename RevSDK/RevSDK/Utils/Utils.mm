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

#include "Utils.hpp"
#include "RSUtils.h"

namespace rs
{
    const int kSDKVersionNumber = kRSSDKVersion;
    
    const std::string kConfigurationLoadedNotification = "kConfigurationLoadedNotification";
    
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
    //11.02.16 Perepelitsa: Add support for “internal_domains_black_list” SDK configuration field
    const std::string kDomainsInternalBlackListKey     = stdStringFromNSString(kRSDomainsInternalBlackListKey); 
    //
    const std::string kConfigsKey                      = stdStringFromNSString(kRSConfigsKey);
    const std::string kDeviceStatsKey                  = "stats";
    const std::string kRequestsStatsKey                = "requests";
    const std::string kLoggingLevelKey                 = stdStringFromNSString(kRSLoggingLevelKey);
    const std::string kSDKKeyKey                       = "sdk_key";
    const std::string kSDKVersionKey                   = "sdk_version";
    const std::string kAppVersionKey                   = "version";
    //10.02.16 Perepelitsa: implementation of constant (json key of the received request)
    const std::string kABTestingOriginOffloadRatioKey  = stdStringFromNSString(kRSABTestingOriginOffloadRatioKey);    
    //10.02.16 Perepelitsa: Add new SDK configuration options
    const std::string kConnectTimeout = stdStringFromNSString(kRSConnectTimeout);                 
    const std::string kDataReceiveTimeout = stdStringFromNSString(kRSDataReceiveTimeout);          
    const std::string kFirstByteTeout = stdStringFromNSString(kRSFirstByteTeout);                 
    const std::string kSDKDomain = stdStringFromNSString(kRSSDKDomain);                  
    const std::string kQuicUDPPort = stdStringFromNSString(kRSQuicUDPPort);                  
    const std::string kFailuresMonitoringInterval = stdStringFromNSString(kRSFailuresMonitoringInterval);      
    const std::string kFailuresFailoverThreshold = stdStringFromNSString(kRSFailuresFailoverThreshold);
    //
    
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
    
    const std::string kRevHostHeader = stdStringFromNSString(kRSRevHostHeader);
    
    const int kRequestsCountMax = 500;
    
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
    
    std::string standardProtocolName()
    {
        return kStandardProtocolName;
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
    
    void p_traceSocketSpeed(int aDataSize)
    {
        static CFAbsoluteTime lastUpd = 0;
        static CFAbsoluteTime interval = 1.0;
        static int dataSizeAccum = 0;
        
        CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
        
        dataSizeAccum += aDataSize;
        
        if (now - lastUpd > interval)
        {
            float speed = (float)dataSizeAccum / (now - lastUpd);
            speed /= 1024.0f;
            NSLog(@"Socket speed: %.1f kb/s", speed);
            lastUpd = now;
            dataSizeAccum = 0;
            return;
        }
    }
    
    void traceSocketSpeed(int aDataSize)
    {
        return;
        dispatch_async(dispatch_get_main_queue(), ^{
            p_traceSocketSpeed(aDataSize);
        });
    }
    
    bool decomposeURL(const std::string& aBaseURL, const std::string& aURL, std::string& aHost, std::string& aPath, std::string& aScheme)
    {
        @autoreleasepool
        {
            NSString* urlStr = [NSString stringWithUTF8String:aURL.c_str()];
            
            if (urlStr.length == 0)
                return false;
            NSURL* url = [NSURL URLWithString:urlStr];
            if (url == nil)
                return false;
            

            NSString* host = url.host;
            NSString* scheme = url.scheme;
            
            if (host == nil || scheme == nil)
            {
                NSString* baseURLStr = [NSString stringWithUTF8String:aBaseURL.c_str()];
                if (baseURLStr == nil)
                    return false;
                NSURL* baseURL = [NSURL URLWithString:baseURLStr];
                if (baseURL == nil)
                    return false;
                
                url = [[NSURL alloc] initWithString:urlStr relativeToURL:baseURL];
                urlStr = url.absoluteString;
                
                host = url.host;
                scheme = url.scheme;
                
                if (host == nil || scheme == nil)
                    return false;
            }
            
            NSRange r        = [urlStr rangeOfString:host];
            r.length        += r.location;
            r.location       = 0;
            
            NSString* path = [urlStr stringByReplacingCharactersInRange:r withString:@""];
            if (path.length > 0)
            {
                if ([path characterAtIndex:0] != '/')
                {
                    path = [@"/" stringByAppendingString:path];
                }
            }
            
            aHost = stdStringFromNSString(host);
            aPath = stdStringFromNSString(path);
            aScheme = stdStringFromNSString(scheme);
        }

        return true;
    }
    const char* notNullString(const std::string& aString)
    {
        if (aString.c_str() != nullptr)
            return aString.c_str();
        return "\0";
    }
    std::string intToStr(int x)
    {
        char buff[12];
        sprintf(buff, "%d", x);
        return std::string(buff);
    }

    std::string longLongToStr(long long x)
    {
        char buff[24];
        sprintf(buff, "%lld", x);
        return std::string(buff);
    }
    
    long long timestampMS()
    {
        CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
        return (long long)(at * 1000);
    }
    
    std::string timestampMSAsStr()
    {
        CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
        long long ms = (long long)(at * 1000);
        char buff[24];
        sprintf(buff, "%lld", ms);
        return std::string(buff);
    }
    
    bool internetConnectionAvailable()
    {
        return _internetConnectionAvailable();
    }

    bool areDomainNamesEqual(const std::string& aDomainName1, const std::string& aDomainName2)
    {
        NSString* name1 = NSStringFromStdString(aDomainName1);
        NSString* name2 = NSStringFromStdString(aDomainName2);
        
        return _areDomainNamesEqual(name1, name2);
    }
    
    bool domainsContainDomainName(const std::vector<std::string>& aDomains, const std::string& aDomainName)
    {
        for (const std::string& domain : aDomains)
        {
            bool areEqual = areDomainNamesEqual(domain, aDomainName);
            
            if (areEqual)
            {
                return true;
            }
        }
        
        return false;
    }
    
    bool isApplicationActive()
    {
        return _isApplicationActive();
    }
    
    void correctURLIfNeeded(std::string& aURL, const std::string& aScheme)
    {
        NSString* URLString            = NSStringFromStdString(aURL);
        NSURLComponents* URLComponents = [NSURLComponents componentsWithString:URLString];
        
        if (URLComponents.scheme == nil)
        {
            URLComponents.scheme = NSStringFromStdString(aScheme);
        }
        
        NSURL* URL = URLComponents.URL;
        URLString  = URL.absoluteString;
        aURL       = stdStringFromNSString(URLString);
    }
    
    std::string executableFilePath()
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = paths.firstObject;
        NSString* path = [basePath stringByAppendingPathComponent:@"none"];
        return std::string([path UTF8String]);
    }
    
    std::string quicLogFilePath()
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = paths.firstObject;
        NSString* path = [basePath stringByAppendingPathComponent:@"quic.log"];
        return std::string([path UTF8String]);
    }
    
    void postNotification(const std::string& aNotificationName)
    {
        NSString* notificationName = NSStringFromStdString(aNotificationName);
        _postNotification(notificationName);
    }
}
