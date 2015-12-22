//
//  Utils.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSPublicConsts.h"
#import "RSUtils.h"

#include "Request.hpp"
#include "Response.hpp"
#include "Data.hpp"
#include "Error.hpp"
#include "Configuration.hpp"

@implementation NSURLRequest(FileRequest)

- (BOOL)isFileRequest
{
    return self.URL && self.URL.isFileURL;
}

@end

//notifications
NSString* const kRSURLProtocolStoppedLoadingNotification = @"kRSURLProtocolStoppedLoadingNotification";

//keys
NSString* const kRSDataKey = @"kRSDataKey";

namespace rs
{
    //version
    const float kRSSDKVersion = 1.0;
    
    //Rev Host
    const std::string kRSRevBaseHost   = "revsdk.net";
    NSString* const kRSRevRedirectHost = @"rev-200.revdn.net";
    const std::string kRSLoadConfigurationEndPoint = "/sdk/config/";
    const std::string kRSReportStatsEndPoint = "/stats";
    const std::string kRSRevLoadConfigurationHost = "iad02-api03.revsw.net";
    
    //codes
    const long kRSNoErrorCode = -10000;
    
    //keys
    NSString* const kRSURLProtocolHandledKey           = @"kRVProtocolHandledKey";
    NSString* const kRSConfigurationStorageKey         = @"kRSConfigurationStorageKey";
    NSString* const kRSRequestDataStorageKey           = @"kRSRequestDataStorageKey";
    NSString* const kRSStatusCodeKey                   = @"status_code";
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
    
    //protocols
    const std::string kRSHTTPSProtocolName = "https";
    
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
        return [NSData dataWithBytes:aData.bytes() length:aData.length()];
    }
    
    std::shared_ptr<Request> requestFromURLRequest(NSURLRequest* aURLRequest)
    {
        std::string URLString                      = stdStringFromNSString(aURLRequest.URL.absoluteString);
        std::string method                         = stdStringFromNSString(aURLRequest.HTTPMethod);
        std::map<std::string, std::string> headers = stdMapFromNSDictionary(aURLRequest.allHTTPHeaderFields);
        Data body                                  = dataFromNSData(aURLRequest.HTTPBody);
        std::shared_ptr<Request> request           = std::make_shared<Request>(URLString, headers, method, body);
        
        return request;
    }
    
    NSURLRequest* URLRequestFromRequest(std::shared_ptr<Request> aRequest)
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
        return URLWithComponents(aScheme, kRSRevBaseHost, aPath);
    }
    
    std::string HTTPSURLWithPath(std::string aPath)
    {
        return URLWithSchemeAndPath(kRSHTTPSProtocolName, aPath);
    }
    
    std::string URLWithPath(std::string aPath)
    {
        return HTTPSURLWithPath(aPath);
    }
    
    std::string _loadConfigurationURL(const std::string& aSDKKey)
    {
        const std::string path = "/v" + std::to_string((int)kRSSDKVersion) + kRSLoadConfigurationEndPoint + aSDKKey;
        return URLWithComponents(kRSHTTPSProtocolName, kRSRevLoadConfigurationHost, path);
    }
    
    std::string _reportStatsURL()
    {
        return "https://stats-api.revsw.net/v1/stats/apps";//URLWithPath(kRSReportStatsEndPoint);
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
    
    Data dataFromRequestAndResponse(NSURLRequest* aRequest, NSHTTPURLResponse* aResponse)
    {
        NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
        NSURL* URL                          = aRequest.URL;
        NSString* URLString                 = URL.absoluteString;
        NSInteger statusCode                = aResponse.statusCode;
        
        dataDictionary[kRSURLKey]        = URLString;
        dataDictionary[kRSStatusCodeKey] = @(statusCode);
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        Data data = dataFromNSData(jsonData);
        
        return data;
    }
    
    bool _isValidURL(std::string aURLString)
    {
        NSString* URLString = NSStringFromStdString(aURLString);
        NSURL* URL          = [NSURL URLWithString:URLString];
        BOOL isValid        = URL.scheme && URL.host;
        
        return isValid;
    }
}