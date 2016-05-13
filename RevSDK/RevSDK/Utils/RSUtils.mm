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

#import <UIKit/UIKit.h>

#import "RSPublicConsts.h"
#import "RSUtils.h"

#include "RSLog.h"
#include "Request.hpp"
#include "Response.hpp"
#include "Data.hpp"
#include "Error.hpp"
#include "Configuration.hpp"
#include "Connection.hpp"
#import "NSURL+RevSDK.h"
#import "RSURLConnectionNative.h"
#import "RSReachability.h"
//10.02.16 Perepelitsa: because it uses the getter "getABTesting..()" of  singletone "Model"
#import "Model.hpp"
//
#define STRVALUE_OR_DEFAULT( x ) (x ? x : @"-")

@implementation NSURLRequest(FileRequest)

- (BOOL)isFileRequest
{
    return self.URL && self.URL.isFileURL;
}

@end

@implementation NSURLRequest(CDescription)

- (const char *)cDescription
{
    return [NSString stringWithFormat:@"URL %@ headers %@", self.URL.absoluteString, self.allHTTPHeaderFields].UTF8String;
}

@end

@implementation NSHTTPURLResponse (CDescription)

- (const char *)cDescription
{
    return [NSString stringWithFormat:@"URL %@ status code %ld headers %@", self.URL.absoluteString, self.statusCode, self.allHeaderFields].UTF8String;
}

@end

//notifications
NSString* const kRSURLProtocolStoppedLoadingNotification = @"kRSURLProtocolStoppedLoadingNotification";

//keys
NSString* const kRSDataKey = @"kRSDataKey";
NSString* const kRSHostKey = @"kRSHostKey";

namespace rs
{
    //version
    const int kRSSDKVersion = 1;
    
    //Rev Host
    //11.02.16 Perepelitsa: remoove kRSRevBaseHost. it will be parameter 
    //const std::string kRSRevBaseHost   = "revsdk.net";
    //
    const std::string kRSLoadConfigurationEndPoint = "/v1/sdk/config/";
    const std::string kRSReportStatsEndPoint = "/stats";
    NSString* const kRSRevLoadConfigurationHost = @"sdk-config-api.revapm.net";
    NSString* const kRSRevHostHeader = @"X-Rev-Host";
    
    //codes
    const long kRSNoErrorCode = -10000;
    const long kRSErrorCodeConfigurationNotValid = 100;
    
    //notifications
    NSString* const kRSURLProtocolDidReceiveDataNotification = @"kRSURLProtocolDidReceiveDataNotification";
    NSString* const kRSURLProtocolDidReceiveResponseNotification = @"kRSURLProtocolDidReceiveResponseNotification";
    
    //keys
    NSString* const kRSURLProtocolHandledKey           = @"kRVProtocolHandledKey";
    NSString* const kRSConfigurationStorageKey         = @"kRSConfigurationStorageKey";
    NSString* const kRSRequestDataStorageKey           = @"kRSRequestDataStorageKey";
    NSString* const kRSLastMileDataStorageKey          = @"kRSLastMileDataStorageKey";
    NSString* const kRSEventsDataStorageKey            = @"kRSEventsDataStorageKey";
    NSString* const kRSURLKey                          = @"url";
    NSString* const kRSOSKey                           = @"os";
    NSString* const kRSAppNameKey                      = @"app_name";
    NSString* const kRSSDKReleaseVersionKey            = @"sdk_release_version";
    NSString* const kRSConfigurationApiURLKey          = @"configuration_api_url";
    NSString* const kRSConfigurationRefreshIntervalKey = @"configuration_refresh_interval_sec";
    NSString* const kRSConfigurationStaleTimeoutKey    = @"configuration_stale_timeout_sec";
    NSString* const kRSEdgeHostKey                     = @"edge_host";
    NSString* const kRSOperationModeKey                = @"operation_mode";
    NSString* const kRSAllowedTransportProtocolsKey    = @"allowed_transport_protocols";
    NSString* const kRSInitialTransportProtocolsKey    = @"initial_transport_protocol";
    NSString* const kRSTransportMonitoringURLKey       = @"transport_monitoring_url";
    NSString* const kRSStatsReportingURLKey            = @"stats_reporting_url";
    NSString* const kRSStatsReportingIntervalKey       = @"stats_reporting_interval_sec";
    NSString* const kRSStatsReportingLevelKey          = @"stats_reporting_level";
    NSString* const kRSStatsReportingMaxRequestsKey    = @"stats_reporting_max_requests_per_report";
    NSString* const kRSDomainsProvisionedListKey       = @"domains_provisioned_list";
    NSString* const kRSDomainsWhiteListKey             = @"domains_white_list";
    NSString* const kRSDomainsBlackListKey             = @"domains_black_list";    
    //11.02.16 Perepelitsa: Add support for “internal_domains_black_list” SDK configuration field
    NSString* const kRSDomainsInternalBlackListKey     = @"internal_domains_black_list";
    //
    NSString* const kRSLoggingLevelKey                 = @"logging_level";
    NSString* const kRSConfigsKey                      = @"configs";
    //10.02.16 Perepelitsa: implementation of constant (json key of the received request)
    NSString* const kRSABTestingOriginOffloadRatioKey  = @"a_b_testing_origin_offload_ratio";
    //10.02.16 Perepelitsa: Add new SDK configuration options
    NSString* const kRSConnectTimeout                  = @"edge_connect_timeout_sec";
    NSString* const kRSDataReceiveTimeout              = @"edge_data_receive_timeout_sec";
    NSString* const kRSFirstByteTeout                  = @"edge_first_byte_timeout_sec";
    NSString* const kRSSDKDomain                       = @"edge_sdk_domain";
    NSString* const kRSQuicUDPPort                     = @"edge_quic_udp_port";
    NSString* const kRSFailuresMonitoringInterval      = @"edge_failures_monitoring_interval_sec";
    NSString* const kRSFailuresFailoverThreshold       = @"edge_failures_failover_threshold_percent";  
    //
    
    //request keys
    NSString* const kRSJKeyConnID    = @"conn_id";
    NSString* const kRSJKeyEncoding    = @"cont_encoding";
    NSString* const kRSJKeyContType   = @"cont_type";
    NSString* const kRSJKeyEndTs    = @"end_ts";
    NSString* const kRSJKeyFirstByteTs    = @"first_byte_ts";
    NSString* const kRSJKeyKeepAliveStatus    = @"keepalive_status";
    NSString* const kRSJKeyLocCacheStatus    = @"local_cache_status";
    NSString* const kRSJKeyMethod    = @"method";
    NSString* const kRSJKeyNetwork    = @"network";
    NSString* const kRSJKeyProtocol    = @"protocol";
    NSString* const kRSJKeyRecDytes    = @"received_bytes";
    NSString* const kRSJKeySentBytes    = @"sent_bytes";
    NSString* const kRSJKeyStartTs    = @"start_ts";
    NSString* const kRSJKeyStatusCode    = @"status_code";
    NSString* const kRSJKeySuccessStatus    = @"success_status";
    NSString* const kRSJKeyTransportProt    = @"transport_protocol";
    NSString* const kRSJKeyDestination = @"destination";
    NSString* const kRSJKeyEdgeTransport = @"edge_transport";
    NSString* const kRSJKeyRevCache = @"x-rev-cache";
    //10.02.16 Perepelitsa: add new constant (json key of the status request)
    NSString* const kRSJKeyABMode    = @"a_b_mode";
    
    //field
    NSString* const kRSiOSField = @"iOS";
    
    //protocols
    NSString* const kRSHTTPSProtocolName = @"https";
    NSString* const kRSQUICProtocolName = @"quic";
    NSString* const kRSStandardProtocolName = @"standard";
    NSString* const kRSRevProtocolName = @"rev";
    NSString* const kRSDataSchemeName = @"data";
    NSString* const kRSMoatBridgeSchemeName = @"moat-bridge";
    
    //log levels
    NSString* const kRSLogLevelNone  = @"none";
    NSString* const kRSLogLevelDebug = @"debug";
    NSString* const kRSLogLevelError = @"error";
    NSString* const kRSLogLevelInfo  = @"info";
    
    //operation mode strings
    NSString* const kRSOperationModeOffString            = @"off";
    NSString* const kRSOperationModeTransferString       = @"transfer_only";
    NSString* const kRSOperationModeReportString         = @"report_only";
    NSString* const kRSOperationModeTransferReportString = @"transfer_and_report";
    
    std::vector<std::string> vectorFromNSArray(NSArray<NSString *>* aArray)
    {
        std::vector<std::string> vector;
        
        for (NSString* string in aArray)
        {
            std::string std_string = stdStringFromNSString(string);
            vector.push_back(std_string);
        }
        
        return vector;
    }
    
    NSArray<NSString *> * NSArrayFromVector(std::vector<std::string> aVector)
    {
        NSMutableArray* array = [NSMutableArray array];
        
        for (auto i = aVector.begin(); i != aVector.end(); i++)
        {
            NSString* string = NSStringFromStdString(*i);
            [array addObject:string];
        }
        
        return array;
    }
    
    Configuration configurationFromNSDictionary(NSDictionary* aDictionary)
    {
        Configuration configuration;
        
        configuration.os                        = stdStringFromNSString(aDictionary[kRSOSKey]);
        configuration.appName                   = stdStringFromNSString(aDictionary[kRSAppNameKey]);
        configuration.sdkReleaseVersion         = [aDictionary[kRSSDKReleaseVersionKey] floatValue];
        configuration.configurationApiURL       = stdStringFromNSString(aDictionary[kRSConfigurationApiURLKey]);
        configuration.refreshInterval           = [aDictionary[kRSConfigurationRefreshIntervalKey] intValue];
        configuration.staleTimeout              = [aDictionary[kRSConfigurationStaleTimeoutKey] intValue];
        configuration.edgeHost                  = stdStringFromNSString(aDictionary[kRSEdgeHostKey]);
        configuration.operationMode             = (RSOperationModeInner)[aDictionary[kRSOperationModeKey] integerValue];
        configuration.allowedProtocols          = vectorFromNSArray(aDictionary[kRSAllowedTransportProtocolsKey]);
        configuration.initialTransportProtocol  = stdStringFromNSString(aDictionary[kRSInitialTransportProtocolsKey]);
        configuration.transportMonitoringURL    = stdStringFromNSString(aDictionary[kRSTransportMonitoringURLKey]);
        configuration.statsReportingURL         = stdStringFromNSString(aDictionary[kRSStatsReportingURLKey]);
        configuration.statsReportingInterval    = [aDictionary[kRSStatsReportingIntervalKey] intValue];
        configuration.statsReportingLevel       = (RSStatsReportingLevel)[aDictionary[kRSStatsReportingLevelKey] intValue];
        configuration.statsReportingMaxRequests = [aDictionary[kRSStatsReportingMaxRequestsKey] intValue];
        configuration.domainsProvisionedList    = vectorFromNSArray(aDictionary[kRSDomainsProvisionedListKey]);
        configuration.domainsWhiteList          = vectorFromNSArray(aDictionary[kRSDomainsWhiteListKey]);
        configuration.domainsBlackList          = vectorFromNSArray(aDictionary[kRSDomainsBlackListKey]);        
        //11.02.16 Perepelitsa: Add support for “internal_domains_black_list” SDK configuration field
        configuration.domainsInternalBlackList  = vectorFromNSArray(aDictionary[kRSDomainsInternalBlackListKey]);
        //
        configuration.loggingLevel              = stdStringFromNSString(aDictionary[kRSLoggingLevelKey]);
        //10.02.16 Perepelitsa: add fields of a/b testing to copying  
        configuration.abTesMode                 = [aDictionary[kRSJKeyABMode] boolValue];
        configuration.abTestingRatio            = [aDictionary[kRSABTestingOriginOffloadRatioKey] intValue];
        //10.02.16 Perepelitsa: Add new SDK configuration options  
        configuration.failuresFailoverThreshold     = [aDictionary[kRSFailuresFailoverThreshold] doubleValue];
        configuration.failuresMonitoringInterval    = [aDictionary[kRSFailuresMonitoringInterval] intValue];
        configuration.quicUDPPort                   = [aDictionary[kRSQuicUDPPort] intValue];
        configuration.SDKDomain                     = [aDictionary[kRSSDKDomain] intValue];
        //
        return configuration;
    }
    
    NSDictionary* NSDictionaryFromConfiguration(const Configuration& aConfiguration)
    {
        NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
        
        dictionary[kRSOSKey]                           = NSStringFromStdString(aConfiguration.os);
        dictionary[kRSAppNameKey]                      = NSStringFromStdString(aConfiguration.appName);
        dictionary[kRSSDKReleaseVersionKey]            = @(aConfiguration.sdkReleaseVersion);
        dictionary[kRSConfigurationApiURLKey]          = NSStringFromStdString(aConfiguration.configurationApiURL);
        dictionary[kRSConfigurationRefreshIntervalKey] = @(aConfiguration.refreshInterval);
        dictionary[kRSConfigurationStaleTimeoutKey]    = @(aConfiguration.staleTimeout);
        dictionary[kRSEdgeHostKey]                     = NSStringFromStdString(aConfiguration.edgeHost);
        dictionary[kRSOperationModeKey]                = @(aConfiguration.operationMode);
        dictionary[kRSAllowedTransportProtocolsKey]    = NSArrayFromVector(aConfiguration.allowedProtocols);
        dictionary[kRSInitialTransportProtocolsKey]    = NSStringFromStdString(aConfiguration.initialTransportProtocol);
        dictionary[kRSTransportMonitoringURLKey]       = NSStringFromStdString(aConfiguration.transportMonitoringURL);
        dictionary[kRSStatsReportingURLKey]            = NSStringFromStdString(aConfiguration.statsReportingURL);
        dictionary[kRSStatsReportingIntervalKey]       = @(aConfiguration.statsReportingInterval);
        dictionary[kRSStatsReportingLevelKey]          = @(aConfiguration.statsReportingLevel);
        dictionary[kRSStatsReportingMaxRequestsKey]    = @(aConfiguration.statsReportingMaxRequests);
        dictionary[kRSDomainsProvisionedListKey]       = NSArrayFromVector(aConfiguration.domainsProvisionedList);
        dictionary[kRSDomainsWhiteListKey]             = NSArrayFromVector(aConfiguration.domainsWhiteList);
        dictionary[kRSDomainsBlackListKey]             = NSArrayFromVector(aConfiguration.domainsBlackList);
        //11.02.16 Perepelitsa: Add support for “internal_domains_black_list” SDK configuration field
         dictionary[kRSDomainsInternalBlackListKey]    = NSArrayFromVector(aConfiguration.domainsInternalBlackList);
        //
        dictionary[kRSLoggingLevelKey]                 = NSStringFromStdString(aConfiguration.loggingLevel);
        //10.02.16 Perepelitsa: add fields of a/b testing to copying  
        dictionary[kRSJKeyABMode]                    = @(aConfiguration.abTesMode);
        dictionary[kRSABTestingOriginOffloadRatioKey]  = @(aConfiguration.abTestingRatio);
        //10.02.16 Perepelitsa: Add new SDK configuration options  
        dictionary[kRSFailuresFailoverThreshold]       = @(aConfiguration.failuresFailoverThreshold);
        dictionary[kRSFailuresMonitoringInterval]      = @(aConfiguration.failuresMonitoringInterval);
        dictionary[kRSQuicUDPPort]                     = @(aConfiguration.quicUDPPort);
        dictionary[kRSSDKDomain]                       = NSStringFromStdString(aConfiguration.SDKDomain);
        //
        return dictionary;
    }
    
    std::string stdStringFromNSString(NSString* aNSString)
    {
        if (!aNSString)
        {
            return "";
        }
        
        return std::string([aNSString UTF8String]);
    }
    
    NSString* NSStringFromStdString(std::string aStdString)
    {
        return [NSString stringWithUTF8String:aStdString.c_str()];
    }
    
    std::map<std::string, std::string> stdMapFromNSDictionary(NSDictionary* aDictionary)
    {
        std::map <std::string, std::string> map;
        
        for (NSString* key in aDictionary)
        {
            NSString* value = aDictionary[key];
           
            if ([value isKindOfClass:[NSString class]])
            {
                std::string std_key   = stdStringFromNSString(key);
                std::string std_value = stdStringFromNSString(value);
                map[std_key]          = std_value;
            }
        }
            
        return map;
    }
    
    NSDictionary* NSDictionaryFromStdMap(std::map<std::string, std::string> aMap)
    {
        NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
        
        for (auto it = aMap.begin(); it != aMap.end(); it++)
        {
            NSString* key   = NSStringFromStdString(it->first);
            NSString* value = NSStringFromStdString(it->second);
            dictionary[key] = value;
        }
        
        return dictionary;
    }
    
    Data dataFromNSData(NSData* aData)
    {
        return Data(aData.bytes, aData.length);
    }
    
    NSData* NSDataFromData(Data aData)
    {
        if (aData.length() == 0)
            return nil;
        return [NSData dataWithBytes:aData.bytes() length:aData.length()];
    }
    
    std::shared_ptr<Request> requestFromURLRequest(NSURLRequest* aURLRequest)
    {
        std::string URLString                      = stdStringFromNSString(aURLRequest.URL.absoluteString);
        std::string method                         = stdStringFromNSString(aURLRequest.HTTPMethod);
        std::map<std::string, std::string> headers = stdMapFromNSDictionary(aURLRequest.allHTTPHeaderFields);
        Data body                                  = dataFromNSData(aURLRequest.HTTPBody);
        std::shared_ptr<Request> request           = std::make_shared<Request>(URLString, headers, method, body);
        request->setHost(stdStringFromNSString(aURLRequest.URL.host));
        request->setPath(stdStringFromNSString(aURLRequest.URL.path));
        
        if (aURLRequest.URL.host)
        {
            NSString* urlStr = aURLRequest.URL.absoluteString;
            NSRange r        = [urlStr rangeOfString:aURLRequest.URL.host];
            r.length        += r.location;
            r.location       = 0;
            
            std::string rString = stdStringFromNSString([urlStr stringByReplacingCharactersInRange:r withString:@""]);
            
            if (rString.length() == 0)
                rString = "/";
            request->setRest(rString);
        }
        
        return request;
    }
    
    NSMutableURLRequest* URLRequestFromRequest(std::shared_ptr<Request> aRequest)
    {
        NSString* URLString          = NSStringFromStdString(aRequest->URL());
        NSURL* URL                   = [NSURL URLWithString:URLString];
        NSString* method             = NSStringFromStdString(aRequest->method());
        NSDictionary* headers        = NSDictionaryFromStdMap(aRequest->headers());
        NSData* body                 = NSDataFromData(aRequest->body());
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:URL];
        request.HTTPBody             = body;
        request.allHTTPHeaderFields  = headers;
        request.HTTPMethod           = method;
        
        return request;
    }
    
    std::shared_ptr<Response> responseFromHTTPURLResponse(NSHTTPURLResponse* aHTTPURLResponse)
    {
        std::string URL                                 = stdStringFromNSString(aHTTPURLResponse.URL.absoluteString);
        std::map<std::string, std::string> headerFields = stdMapFromNSDictionary(aHTTPURLResponse.allHeaderFields);
        unsigned long statusCode                        = aHTTPURLResponse.statusCode;
        
        return std::make_shared<Response>(URL, headerFields, statusCode);
    }
    
    NSHTTPURLResponse* NSHTTPURLResponseFromResponse(std::shared_ptr<Response> aResponse)
    {
        if (aResponse.get() == nullptr)
            return nil;
        NSString* URLString         = NSStringFromStdString(aResponse.get()->URL());
        NSURL* URL                  = [NSURL URLWithString:URLString];
        NSDictionary* headerFields  = NSDictionaryFromStdMap(aResponse.get()->headerFields());
        NSInteger statusCode        = aResponse.get()->statusCode();
        NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:URL
                                                                  statusCode:statusCode
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:headerFields];
        return response;
    }
    
    Error errorFromNSError(NSError* aError)
    {
        if (!aError)
        {
           return Error::notError();
        }
        
        Error error;
        error.code     = aError.code;
        error.domain   = stdStringFromNSString(aError.domain);
        error.userInfo = stdMapFromNSDictionary(aError.userInfo);
        return error;
    }
    
    NSError* NSErrorFromError(Error aError)
    {
        NSString* domain       = NSStringFromStdString(aError.domain);
        NSDictionary* userInfo = NSDictionaryFromStdMap(aError.userInfo);
        
        return [NSError errorWithDomain:domain
                                   code:aError.code
                               userInfo:userInfo];
    }
    
    std::string URLWithComponents(std::string aScheme, std::string aHost, std::string aPath)
    {
        NSString* scheme               = NSStringFromStdString(aScheme);
        NSString* host                 = NSStringFromStdString(aHost);
        NSString* path                 = NSStringFromStdString(aPath);
        NSURLComponents* URLComponents = [NSURLComponents new];
        URLComponents.scheme           = scheme;
        URLComponents.host             = host;
        URLComponents.path             = path;
        NSURL* URL                     = [URLComponents URL];
        NSString* URLString            = URL.absoluteString;
        std::string stdURLString       = stdStringFromNSString(URLString);
        
        return stdURLString;
    }
    
    std::string URLWithSchemeAndPath(std::string aScheme, std::string aPath)
    {
        return URLWithComponents(aScheme, rs::Model::instance()->revBaseHost(), aPath);
    }
    
    std::string HTTPSURLWithPath(std::string aPath)
    {
        return URLWithSchemeAndPath(kHTTPSProtocolName, aPath);
    }
    
    std::string URLWithPath(std::string aPath)
    {
        return HTTPSURLWithPath(aPath);
    }
    
    std::string _loadConfigurationURL(const std::string& aSDKKey)
    {
        const std::string path = kRSLoadConfigurationEndPoint + aSDKKey;
        return URLWithComponents(kHTTPSProtocolName, stdStringFromNSString(kRSRevLoadConfigurationHost), path);
    }
    
    std::vector<Data> dataNSArrayToStdVector(NSArray * aArray)
    {
        std::vector<Data> dataVector = std::vector<Data>();
        
        for (NSData* data in aArray)
        {
            assert([data isKindOfClass:[NSData class]]);
            Data rsData = dataFromNSData(data);
            dataVector.push_back(rsData);
        }
            
        return dataVector;
    }
    
    Data dataFromRequestsDictionary(NSURLRequest* aRequest, NSHTTPURLResponse* aResponse, NSDictionary* aDictionary, BOOL aIsRedirecting)
    {
        NSNumber* startTimestamp     = aDictionary[kRSJKeyStartTs];
        NSNumber* endTimestamp       = aDictionary[kRSJKeyEndTs];
        NSNumber* firstByteTimestamp = aDictionary[kRSJKeyFirstByteTs];
        
        CFNumberRef stRef  = (__bridge CFNumberRef)startTimestamp;
        CFNumberRef endRef = (__bridge CFNumberRef)endTimestamp;
        CFNumberRef fbRef  = (__bridge CFNumberRef)firstByteTimestamp;
        
        if (CFNumberIsFloatType(stRef))
        {
            Log::error(kLogTagSDKStats, "Start timestamp is not an integer");
        }
        
        if (CFNumberIsFloatType(endRef))
        {
            Log::error(kLogTagSDKStats, "End timestamp is not an integer");
        }
        
        if (CFNumberIsFloatType(fbRef))
        {
            Log::error(kLogTagSDKStats, "End timestamp is not an integer");
        }
        
        if ([startTimestamp isEqualToNumber:firstByteTimestamp])
        {
            Log::error(kLogTagSDKStats, "First byte timestamp is equal to start timestamp");
        }
        
        NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
        NSDictionary* headers               = aRequest.allHTTPHeaderFields;
        NSURL* URL                          = aRequest.URL;
        NSURL* originalURL                  = URL;
        
        if (aIsRedirecting)
            originalURL = [originalURL revURLByReplacingHostWithHost:headers[kRSRevHostHeader]];
        
        NSString* URLString                 = [originalURL absoluteString];
        NSInteger statusCode                = aResponse ? aResponse.statusCode : 0;
        BOOL successStatus                  = aResponse.statusCode >= 200 && aResponse.statusCode < 300;
        
        dataDictionary[kRSURLKey]           = URLString;
        dataDictionary[kRSJKeyStatusCode] = @(statusCode);
        dataDictionary[kRSJKeySuccessStatus] = @((int)successStatus);
        
        int successStatusCheck = [dataDictionary[kRSJKeySuccessStatus] intValue];
        
        if (successStatusCheck != 0 && successStatusCheck != 1)
        {
            std::string logFormat = "success statuc is incorrect " + std::to_string(successStatusCheck);
            Log::error(kLogTagSDKStats, logFormat.c_str());
        }
        
        //fill with defaults
        {
            NSNumber *defaultVal = [NSNumber numberWithInt:0];
            dataDictionary[kRSJKeyEncoding] 		= @"-";
            dataDictionary[kRSJKeyContType] 		= @"-";
            dataDictionary[kRSJKeyEndTs] 			= defaultVal;
            dataDictionary[kRSJKeyFirstByteTs]      = defaultVal;
            dataDictionary[kRSJKeyKeepAliveStatus]  = defaultVal;
            dataDictionary[kRSJKeyLocCacheStatus]   = @"-";
            dataDictionary[kRSJKeyMethod]           = @"-";
            dataDictionary[kRSJKeyNetwork]          = @"-";
            dataDictionary[kRSJKeyProtocol] 		= @"-";
            dataDictionary[kRSJKeyRecDytes] 		= defaultVal;
            dataDictionary[kRSJKeySentBytes] 		= defaultVal;
            dataDictionary[kRSJKeyStartTs]          = defaultVal;
            dataDictionary[kRSJKeyTransportProt] 	= @"-";
            dataDictionary[kRSJKeyDestination]      = @"_";
            dataDictionary[kRSJKeyEdgeTransport]    = @"_";
            //
        }
        // fetching data
        {
            dataDictionary[kRSJKeyConnID] = aDictionary[kRSJKeyConnID];
            dataDictionary[kRSJKeyMethod] = [aRequest HTTPMethod];

            
            if (aResponse)
            {
                NSDictionary* headers = [aResponse allHeaderFields];
                
                dataDictionary[kRSJKeyEncoding]         = STRVALUE_OR_DEFAULT(headers[@"Content-Encoding"]);
                dataDictionary[kRSJKeyContType]         = STRVALUE_OR_DEFAULT(headers[@"Content-Type"]);
                dataDictionary[kRSJKeyLocCacheStatus]   = STRVALUE_OR_DEFAULT(headers[@"Cache-Control"]);;
                dataDictionary[kRSJKeyTransportProt]    = aDictionary[kRSJKeyTransportProt];//aRequest.URL.scheme;
                
                dataDictionary[kRSJKeyStartTs]          = startTimestamp;
                dataDictionary[kRSJKeyRecDytes] 		= aDictionary[kRSJKeyRecDytes];
                dataDictionary[kRSJKeySentBytes] 		= aDictionary[kRSJKeySentBytes];
                dataDictionary[kRSJKeyEndTs] 			= endTimestamp;
                dataDictionary[kRSJKeyFirstByteTs]      = firstByteTimestamp;
                
                dataDictionary[kRSJKeyKeepAliveStatus]  = [NSNumber numberWithInt:1];
                dataDictionary[kRSJKeyDestination]      = aIsRedirecting ? @"rev_edge" : @"origin";
                dataDictionary[kRSJKeyEdgeTransport]    = aDictionary[kRSJKeyEdgeTransport];
                
                NSString* revCache = aResponse.allHeaderFields[kRSJKeyRevCache];
                dataDictionary[kRSJKeyRevCache] = STRVALUE_OR_DEFAULT(revCache);
            }
        }
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        Data data = dataFromNSData(jsonData);
        
        return data;
    }
    
    Data dataFromRequestAndResponse(NSURLRequest* aRequest, NSHTTPURLResponse* aResponse, Connection* aConnection, NSString* aOriginalScheme, BOOL aIsRedirecting)
    {
        NSDictionary* dictionary = @{
                                     kRSJKeyConnID : @(aConnection->getID()),
                                     kRSJKeyStartTs : @(aConnection->getStartTimestamp()),
                                     kRSJKeyRecDytes : @(aConnection->getTotalReceived()),
                                     kRSJKeySentBytes : @(aConnection->getTotalSent()),
                                     kRSJKeyEndTs : @(aConnection->getEndTimestamp()),
                                     kRSJKeyFirstByteTs : @(aConnection->getFirstByteTimestamp()),
                                     kRSJKeyTransportProt : aOriginalScheme,
                                     kRSJKeyEdgeTransport : NSStringFromStdString(aConnection->edgeTransport())
                                     
                                     };
        
        return dataFromRequestsDictionary(aRequest, aResponse, dictionary, aIsRedirecting);
    }
    
    Data dataFromConnection(RSURLConnectionNative* aConnection, BOOL aIsRedirecting)
    {
        NSURLRequest* request       = aConnection.request;
        NSHTTPURLResponse* response = aConnection.response;
        
        NSDictionary* dictionary = @{
                                     kRSJKeyConnID : aConnection.connectionId,
                                     kRSJKeyStartTs : aConnection.startTimestamp,
                                     kRSJKeyRecDytes : aConnection.totalBytesReceived,
                                     kRSJKeySentBytes : @(request.HTTPBody.length),
                                     kRSJKeyEndTs : aConnection.endTimestamp,
                                     kRSJKeyFirstByteTs : aConnection.firstByteTimestamp ? aConnection.firstByteTimestamp : @(0),
                                     kRSJKeyTransportProt : request.URL.scheme,
                                     kRSJKeyEdgeTransport : @"_"
                                     };
        
        return dataFromRequestsDictionary(request, response, dictionary, aIsRedirecting);
    }
    
    bool _isValidURL(NSString* aURLString)
    {
        if (![aURLString isKindOfClass:[NSString class]])
        {
            return false;
        }
        
        NSURL* URL   = [NSURL URLWithString:aURLString];
        BOOL isValid = URL.scheme && URL.host;
        
        return isValid;
    }
    
    bool _isValidConfiguration(const Data& aConfData, Error* aError)
    {
        if (aConfData.length() == 0)
        {
            return false;
        }
        
        NSData* data = NSDataFromData(aConfData);
        
        if (!data)
        {
            return false;
        }
        
        NSDictionary* confDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:kNilOptions
                                                                         error:nil];
        if (!confDictionary)
        {
            return false;
        }
        
        std::string errorDescrKey = errorDescriptionKey();
        
        NSString* osString = confDictionary[kRSOSKey];
        
        if (![osString isKindOfClass:[NSString class]] || ![osString isEqualToString:kRSiOSField])
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "OS incorrect " + stdStringFromNSString(osString)}};
            
            return false;
        }
        
        NSArray* configsArray     = confDictionary[kRSConfigsKey];
        NSDictionary* configsDict = [configsArray lastObject];
        
        if (![configsDict isKindOfClass:[NSDictionary class]])
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "configs missing"}};
            
            return false;
        }
        
        NSArray* allowedTransportProtocols = configsDict[kRSAllowedTransportProtocolsKey];
        
        if (! [allowedTransportProtocols isKindOfClass:[NSArray class]] || [allowedTransportProtocols count] == 0)
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "allowed transport protocols invalid " + stdStringFromNSString([allowedTransportProtocols description])}};
            
            return false;
        }
        
        NSString* configurationApiURL = configsDict[kRSConfigurationApiURLKey];
        
        if (!_isValidURL(configurationApiURL))
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "configuration api url invalid " + stdStringFromNSString(configurationApiURL)}};
            
            return false;
        }
        
        id refreshInterval = configsDict[kRSConfigurationRefreshIntervalKey];
        
        if (!([refreshInterval respondsToSelector:@selector(integerValue)] && [refreshInterval integerValue] > 0))
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "configuration refresh interval invalid " + stdStringFromNSString([refreshInterval description])}};
            
            return false;
        }
       
        id staleTimeout = configsDict[kRSConfigurationStaleTimeoutKey];
        
        if (!([staleTimeout respondsToSelector:@selector(integerValue)] && [staleTimeout integerValue] > 0))
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "stale timeout invalid " + stdStringFromNSString([staleTimeout description])}};
            
            return false;
        }
        
        NSArray* blackList = configsDict[kRSDomainsBlackListKey];    
        
        if (![blackList isKindOfClass:[NSArray class]])
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "configuration refresh interval invalid " + stdStringFromNSString([refreshInterval description])}};
            
            return false;
        }
        
//        11.02.16 Perepelitsa: Add support for “internal_domains_black_list” SDK configuration field
//        11.02.16 Perepelitsa: "internal_domains_black_list" not yet implemented on the server
        
//        NSArray* blackListInternal = configsDict[kRSDomainsInternalBlackListKey];        
//                 
//        if ( ![blackListInternal isKindOfClass:[NSArray class]])
//        {
//            (*aError).code = kRSErrorCodeConfigurationNotValid;
//            (*aError).userInfo = {{errorDescrKey, "configuration refresh interval invalid " + stdStringFromNSString([refreshInterval description])}};
//            
//            return false;
//        }
        
        
        NSArray* provisionedList = configsDict[kRSDomainsProvisionedListKey];
        
        if (![provisionedList isKindOfClass:[NSArray class]])
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "provisioned list invalid " + stdStringFromNSString([provisionedList description])}};
            
            return false;
        }
        
        NSString* edgeHost = configsDict[kRSEdgeHostKey];
        
        if (![edgeHost isKindOfClass:[NSString class]] || edgeHost.length == 0)
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "edge host invalid " + stdStringFromNSString([edgeHost description])}};
            
            return false;
        }
        
        NSString* initialTransportProtocol = configsDict[kRSInitialTransportProtocolsKey];
        
        if (! [initialTransportProtocol isKindOfClass:[NSString class]] || ![@[kRSStandardProtocolName, kRSQUICProtocolName, kRSRevProtocolName] containsObject:initialTransportProtocol])
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "initial transport protocol invalid " + stdStringFromNSString([initialTransportProtocol description])}};
            
            return false;
        }
        
        NSString* loggingLevel = configsDict[kRSLoggingLevelKey];

        if (![loggingLevel isKindOfClass:[NSString class]] || ![@[kRSLogLevelDebug, kRSLogLevelError, kRSLogLevelInfo] containsObject:loggingLevel])
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "logging level invalid " + stdStringFromNSString([loggingLevel description])}};
            
            return false;
        }
        
        NSString* operationMode = configsDict[kRSOperationModeKey];
        
        if (! [operationMode isKindOfClass:[NSString class]] || ![@[kRSOperationModeOffString, kRSOperationModeTransferString, kRSOperationModeReportString, kRSOperationModeTransferReportString] containsObject:operationMode])
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "operation mode invalid " + stdStringFromNSString([operationMode description])}};
            
            return false;
        }
        
        id releaseVersion = configsDict[kRSSDKReleaseVersionKey];
        
        if (! ([releaseVersion respondsToSelector:@selector(intValue)] && [releaseVersion intValue] == kRSSDKVersion))
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "sdk release version invalid " + stdStringFromNSString([releaseVersion description])}};
            
            return false;
        }
        
        id statsReportingInterval = configsDict[kRSStatsReportingIntervalKey];
        
        if (!([statsReportingInterval respondsToSelector:@selector(integerValue)] && [statsReportingInterval integerValue] > 0))
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "stats reporting interval invalid " + stdStringFromNSString([statsReportingInterval description])}};
            
            return false;
        }
        
        NSString* statsReportingLevel = configsDict[kRSStatsReportingLevelKey];
        
        if (!([statsReportingLevel isKindOfClass:[NSString class]] && statsReportingLevel.length > 0))
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "stats reporting level invalid " + stdStringFromNSString([statsReportingLevel description])}};
            
            return false;
        }
        
        id maxRequests = configsDict[kRSStatsReportingMaxRequestsKey];
        
        if (!([maxRequests respondsToSelector:@selector(intValue)] && [maxRequests intValue] > 0))
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "max requests per request invalid " + stdStringFromNSString([maxRequests description])}};
            
            return false;
        }
        
        NSString* statsReportingURL = configsDict[kRSStatsReportingURLKey];
        
        if (! _isValidURL(statsReportingURL))
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "stats reporting url invalid " + stdStringFromNSString([statsReportingURL description])}};
            
            return false;
        }
        
        NSString* transportMonitoringURL = configsDict[kRSTransportMonitoringURLKey];
        
        if (!_isValidURL(transportMonitoringURL))
        {
            (*aError).code = kRSErrorCodeConfigurationNotValid;
            (*aError).userInfo = {{errorDescrKey, "transport monitoring url invalid " + stdStringFromNSString([transportMonitoringURL description])}};
            
            return false;
        }
        
        return true;
    }
    
     bool _internetConnectionAvailable()
     {
         RSReachability* reachability = [RSReachability rs_reachabilityForInternetConnection];
         
         return reachability.rs_currentReachabilityStatus != kRSNotReachable;
     }
    
    bool _areDomainNamesEqual(NSString* aDomainName1, NSString* aDomainName2)
    {
        if (![aDomainName1 hasPrefix:@"http://"] && ![aDomainName1 hasPrefix:@"https://"])
        {
            aDomainName1 = [@"http://" stringByAppendingString:aDomainName1];
        }
        
        if (![aDomainName2 hasPrefix:@"http://"] && ![aDomainName2 hasPrefix:@"https://"])
        {
            aDomainName2 = [@"http://" stringByAppendingString:aDomainName2];
        }
        
        NSURL* URL1 = [NSURL URLWithString:aDomainName1];
        NSURL* URL2 = [NSURL URLWithString:aDomainName2];
        
        NSString* host1 = URL1.host;
        NSString* host2 = URL2.host;
        
        return [host1 isEqualToString:host2];
    }
    
    bool _isApplicationActive()
    {
        return [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
    }
    
    void _postNotification(NSString * aNotificationName, NSString* aInfo)
    {
        NSDictionary* userInfo = @{
                                   @"info_key" : aInfo
                                   };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:aNotificationName
                                                            object:nil
                                                          userInfo:userInfo];
    }
}