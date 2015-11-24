//
//  Utils.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSUtils.h"
#include "Request.hpp"
#include "Response.hpp"
#include "Data.hpp"
#include "Error.hpp"
#include "Configuration.hpp"

namespace rs
{
    //codes
    const long kRSNoErrorCode = -10000;
    
    //keys
    NSString* const kRSURLProtocolHandledKey = @"kRVProtocolHandledKey";
    const std::string kRSErrorDescriptionKey = "NSLocalizedDescription";
    NSString* const kRSConfigurationStorageKey = @"kRSConfigurationStorageKey";
    
    //protocols
    const std::string kRSHTTPSProtocolName = "https";
    
    //edge host
    const std::string kRSEdgeHost = "rev-200.revdn.net";
    
    NSString* absoluteURLStringFromEndPoint(NSString* aEndPoint)
    {
        NSString* host = NSStringFromStdString(kRSEdgeHost);
        return [NSString stringWithFormat:@"https://%@/%@", host, aEndPoint];
    }
    
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
        
        configuration.os                        = stdStringFromNSString(aDictionary[@"os"]);
        configuration.appName                   = stdStringFromNSString(aDictionary[@"app_name"]);
        configuration.sdkReleaseVersion         = [aDictionary[@"sdk_release_version"] floatValue];
        configuration.configurationApiURL       = stdStringFromNSString(aDictionary[@"configuration_api_url"]);
        configuration.refreshInterval           = [aDictionary[@"configuration_refresh_interval_sec"] intValue];
        configuration.staleTimeout              = [aDictionary[@"configuration_stale_timeout_sec"] intValue];
        configuration.edgeHost                  = stdStringFromNSString(aDictionary[@"edge_host"]);
        configuration.operationMode             = stdStringFromNSString(aDictionary[@"operation_mode"]);
        configuration.allowedProtocols          = vectorFromNSArray(aDictionary[@"allowed_transport_protocols"]);
        configuration.initialTransportProtocol  = stdStringFromNSString(aDictionary[@"initial_transport_protocol"]);
        configuration.transportMonitoringURL    = stdStringFromNSString(aDictionary[@"transport_monitoring_url"]);
        configuration.statsReportingURL         = stdStringFromNSString(aDictionary[@"stats_reporting_url"]);
        configuration.statsReportingInterval    = [aDictionary[@"stats_reporting_interval_sec"] intValue];
        configuration.statsReportingLevel       = stdStringFromNSString(aDictionary[@"stats_reporting_level"]);
        configuration.statsReportingMaxRequests = [aDictionary[@"stats_reporting_max_requests_per_report"] intValue];
        configuration.domainsProvisionedList    = vectorFromNSArray(aDictionary[@"domains_provisioned_list"]);
        configuration.domainsWhiteList          = vectorFromNSArray(aDictionary[@"domains_white_list"]);
        configuration.domainsBlackList          = vectorFromNSArray(aDictionary[@"domains_black_list"]);
        
        return configuration;
    }
    
    NSDictionary* NSDictionaryFromConfiguration(const Configuration& aConfiguration)
    {
        NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
        
        dictionary[@"os"]                                      = NSStringFromStdString(aConfiguration.os);
        dictionary[@"app_name"]                                = NSStringFromStdString(aConfiguration.appName);
        dictionary[@"sdk_release_version"]                     = @(aConfiguration.sdkReleaseVersion);
        dictionary[@"configuration_api_url"]                   = NSStringFromStdString(aConfiguration.configurationApiURL);
        dictionary[@"configuration_refresh_interval_sec"]      = @(aConfiguration.refreshInterval);
        dictionary[@"configuration_stale_timeout_sec"]         = @(aConfiguration.staleTimeout);
        dictionary[@"edge_host"]                               = NSStringFromStdString(aConfiguration.edgeHost);
        dictionary[@"operation_mode"]                          = NSStringFromStdString(aConfiguration.operationMode);
        dictionary[@"allowed_transport_protocols"]             = NSArrayFromVector(aConfiguration.allowedProtocols);
        dictionary[@"initial_transport_protocol"]              = NSStringFromStdString(aConfiguration.initialTransportProtocol);
        dictionary[@"transport_monitoring_url"]                = NSStringFromStdString(aConfiguration.transportMonitoringURL);
        dictionary[@"stats_reporting_url"]                     = NSStringFromStdString(aConfiguration.statsReportingURL);
        dictionary[@"stats_reporting_interval_sec"]            = @(aConfiguration.statsReportingInterval);
        dictionary[@"stats_reporting_level"]                   = NSStringFromStdString(aConfiguration.statsReportingLevel);
        dictionary[@"stats_reporting_max_requests_per_report"] = @(aConfiguration.statsReportingMaxRequests);
        dictionary[@"domains_provisioned_list"]                = NSArrayFromVector(aConfiguration.domainsProvisionedList);
        dictionary[@"domains_white_list"]                      = NSArrayFromVector(aConfiguration.domainsWhiteList);
        dictionary[@"domains_black_list"]                      = NSArrayFromVector(aConfiguration.domainsBlackList);
        
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
        NSUInteger length = aData.length;
        Byte *byteData    = (Byte*) malloc(length);
        memcpy(byteData, [aData bytes], length);
        
        Data data;
        data.bytes  = byteData;
        data.length = length;
        
        return data;
    }
    
    NSData* NSDataFromData(Data aData)
    {
        return [NSData dataWithBytes:aData.bytes length:aData.length];
    }
    
    std::shared_ptr<Request> requestFromURLRequest(NSURLRequest* aURLRequest)
    {
        std::string URLString            = stdStringFromNSString(aURLRequest.URL.absoluteString);
        std::shared_ptr<Request> request = std::make_shared<Request>(URLString);
        
        return request;
    }
    
    NSURLRequest* URLRequestFromRequest(std::shared_ptr<Request> aRequest)
    {
        NSString* URLString = NSStringFromStdString(aRequest.get()->URL());
        NSURL* URL          = [NSURL URLWithString:URLString];
        
        return [NSURLRequest requestWithURL:URL];
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
}