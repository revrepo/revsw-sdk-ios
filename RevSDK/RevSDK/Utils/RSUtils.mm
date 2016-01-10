//
//  Utils.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

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

#define STRVALUE_OR_DEFAULT( x ) (x ? x : @"-")

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
    const int kRSSDKVersion = 1;
    
    //Rev Host
    const std::string kRSRevBaseHost   = "revsdk.net";
    NSString* const kRSRevRedirectHost = @"rev-200.revdn.net";
    const std::string kRSLoadConfigurationEndPoint = "/sdk/config/";
    const std::string kRSReportStatsEndPoint = "/stats";
    NSString* const kRSRevLoadConfigurationHost = @"iad02-api03.revsw.net";
    NSString* const kRSRevHostHeader = @"X-Rev-Host";
    
    //codes
    const long kRSNoErrorCode = -10000;
    const long kRSErrorCodeConfigurationNotValid = 100;
    
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
    NSString* const kRSLoggingLevelKey                 = @"logging_level";
    NSString* const kRSConfigsKey                      = @"configs";
    
    //request keys
    NSString* const kRS_JKey_ConnID    = @"conn_id";
    NSString* const kRS_JKey_Encoding    = @"cont_encoding";
    NSString* const kRS_JKey_ContType   = @"cont_type";
    NSString* const kRS_JKey_EndTs    = @"end_ts";
    NSString* const kRS_JKey_FirstByteTs    = @"first_byte_ts";
    NSString* const kRS_JKey_KeepAliveStatus    = @"keepalive_status";
    NSString* const kRS_JKey_LocCacheStatus    = @"local_cache_status";
    NSString* const kRS_JKey_Method    = @"method";
    NSString* const kRS_JKey_Network    = @"network";
    NSString* const kRS_JKey_Protocol    = @"protocol";
    NSString* const kRS_JKey_RecDytes    = @"received_bytes";
    NSString* const kRS_JKey_SentBytes    = @"sent_bytes";
    NSString* const kRS_JKey_StartTs    = @"start_ts";
    NSString* const kRS_JKey_StatusCode    = @"status_code";
    NSString* const kRS_JKey_SuccessStatus    = @"success_status";
    NSString* const kRS_JKey_TransportProt    = @"transport_protocol";
    NSString* const kRS_JKey_Destination = @"destination";
    NSString* const kRS_JKey_EdgeTransport = @"edge_transport";
    NSString* const kRS_JKey_RevCache = @"x-rev-cache";
    
    //field
    NSString* const kRSiOSField = @"iOS";
    
    //protocols
    NSString* const kRSHTTPSProtocolName = @"https";
    NSString* const kRSQUICProtocolName = @"quic";
    NSString* const kRSStandardProtocolName = @"standard";
    NSString* const kRSRevProtocolName = @"rev";
    NSString* const kRSDataSchemeName = @"data";
    
    //log levels
    NSString* const kRSLogLevelNone  = @"none";
    NSString* const kRSLogLevelDebug = @"debug";
    NSString* const kRSLogLevelError = @"error";
    NSString* const kRSLogLevelInfo  = @"info";
    
    //operation mode strings
    NSString* const kRSOperationModeOffString            = @"off";
    NSString* const kRSOperationModeTransferString       = @"transfer";
    NSString* const kRSOperationModeReportString         = @"report";
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
        configuration.loggingLevel              = stdStringFromNSString(aDictionary[kRSLoggingLevelKey]);
        
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
        dictionary[kRSLoggingLevelKey]                 = NSStringFromStdString(aConfiguration.loggingLevel);
        
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
        return URLWithComponents(aScheme, kRSRevBaseHost, aPath);
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
        const std::string path = "/v" + std::to_string((int)kRSSDKVersion) + kRSLoadConfigurationEndPoint + aSDKKey;
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
    
    Data dataFromRequestsDictionary(NSURLRequest* aRequest, NSHTTPURLResponse* aResponse, NSDictionary* aDictionary)
    {
        NSNumber* startTimestamp     = aDictionary[kRS_JKey_StartTs];
        NSNumber* endTimestamp       = aDictionary[kRS_JKey_EndTs];
        NSNumber* firstByteTimestamp = aDictionary[kRS_JKey_FirstByteTs];
        
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
        BOOL isRedirecting                  = [URL.host isEqualToString:kRSRevRedirectHost];
        
        if (isRedirecting)
            originalURL = [originalURL revURLByReplacingHostWithHost:headers[kRSRevHostHeader]];
        
        NSString* URLString                 = [originalURL absoluteString];
        NSInteger statusCode                = aResponse ? aResponse.statusCode : 0;
        BOOL successStatus                  = aResponse.statusCode >= 200 && aResponse.statusCode < 300;
        
        dataDictionary[kRSURLKey]           = URLString;
        dataDictionary[kRS_JKey_StatusCode] = @(statusCode);
        dataDictionary[kRS_JKey_SuccessStatus] = @((int)successStatus);
        
        int successStatusCheck = [dataDictionary[kRS_JKey_SuccessStatus] intValue];
        
        if (successStatusCheck != 0 && successStatusCheck != 1)
        {
            std::string logFormat = "success statuc is incorrect " + std::to_string(successStatusCheck);
            Log::error(kLogTagSDKStats, logFormat.c_str());
        }
        
        //fill with defaults
        {
            NSNumber *defaultVal = [NSNumber numberWithInt:0];
            dataDictionary[kRS_JKey_Encoding] 		= @"-";
            dataDictionary[kRS_JKey_ContType] 		= @"-";
            dataDictionary[kRS_JKey_EndTs] 			= defaultVal;
            dataDictionary[kRS_JKey_FirstByteTs] 	= defaultVal;
            dataDictionary[kRS_JKey_KeepAliveStatus]= defaultVal;
            dataDictionary[kRS_JKey_LocCacheStatus] = @"-";
            dataDictionary[kRS_JKey_Method] 		= @"-";
            dataDictionary[kRS_JKey_Network] 		= @"-";
            dataDictionary[kRS_JKey_Protocol] 		= @"-";
            dataDictionary[kRS_JKey_RecDytes] 		= defaultVal;
            dataDictionary[kRS_JKey_SentBytes] 		= defaultVal;
            dataDictionary[kRS_JKey_StartTs] 		= defaultVal;
            dataDictionary[kRS_JKey_TransportProt] 	= @"-";
            dataDictionary[kRS_JKey_Destination]    = @"_";
            dataDictionary[kRS_JKey_EdgeTransport]  = @"_";
        }
        // fetching data
        {
            dataDictionary[kRS_JKey_ConnID] = aDictionary[kRS_JKey_ConnID];
            dataDictionary[kRS_JKey_Method] = [aRequest HTTPMethod];

            
            if (aResponse)
            {
                NSDictionary* headers = [aResponse allHeaderFields];
                
                dataDictionary[kRS_JKey_Encoding]   = STRVALUE_OR_DEFAULT(headers[@"Content-Encoding"]);
                dataDictionary[kRS_JKey_ContType]   = STRVALUE_OR_DEFAULT(headers[@"Content-Type"]);
                dataDictionary[kRS_JKey_LocCacheStatus] = STRVALUE_OR_DEFAULT(headers[@"Cache-Control"]);;
                dataDictionary[kRS_JKey_TransportProt] = aDictionary[kRS_JKey_TransportProt];//aRequest.URL.scheme;
                
                dataDictionary[kRS_JKey_StartTs] 		= startTimestamp;
                dataDictionary[kRS_JKey_RecDytes] 		= aDictionary[kRS_JKey_RecDytes];
                dataDictionary[kRS_JKey_SentBytes] 		= aDictionary[kRS_JKey_SentBytes];
                dataDictionary[kRS_JKey_EndTs] 			= endTimestamp;
                dataDictionary[kRS_JKey_FirstByteTs] 	= firstByteTimestamp;
                
                dataDictionary[kRS_JKey_KeepAliveStatus]= [NSNumber numberWithInt:1];
                dataDictionary[kRS_JKey_Destination]    = isRedirecting ? @"rev_edge" : @"origin";
                dataDictionary[kRS_JKey_EdgeTransport]  = aDictionary[kRS_JKey_EdgeTransport];
                
                NSString* revCache = aResponse.allHeaderFields[kRS_JKey_RevCache];
                dataDictionary[kRS_JKey_RevCache] = revCache ? revCache : @"_";
            }
        }
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dataDictionary
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        Data data = dataFromNSData(jsonData);
        
        return data;
    }
    
    Data dataFromRequestAndResponse(NSURLRequest* aRequest, NSHTTPURLResponse* aResponse, Connection* aConnection, NSString* aOriginalScheme)
    {
        NSDictionary* dictionary = @{
                                     kRS_JKey_ConnID : @(aConnection->getID()),
                                     kRS_JKey_StartTs : @(aConnection->getStartTimestamp()),
                                     kRS_JKey_RecDytes : @(aConnection->getTotalReceived()),
                                     kRS_JKey_SentBytes : @(aConnection->getTotalSent()),
                                     kRS_JKey_EndTs : @(aConnection->getEndTimestamp()),
                                     kRS_JKey_FirstByteTs : @(aConnection->getFirstByteTimestamp()),
                                     kRS_JKey_TransportProt : aOriginalScheme,
                                     kRS_JKey_EdgeTransport : NSStringFromStdString(aConnection->edgeTransport())
                                     
                                     };
        
        return dataFromRequestsDictionary(aRequest, aResponse, dictionary);
    }
    
    Data dataFromRequestAndResponse(NSURLRequest* aRequest, NSHTTPURLResponse* aResponse, RSURLConnectionNative* aConnection)
    {
        NSDictionary* dictionary = @{
                                     kRS_JKey_ConnID : aConnection.connectionId,
                                     kRS_JKey_StartTs : aConnection.startTimestamp,
                                     kRS_JKey_RecDytes : aConnection.totalBytesReceived,
                                     kRS_JKey_SentBytes : @(aRequest.HTTPBody.length),
                                     kRS_JKey_EndTs : aConnection.endTimestamp,
                                     kRS_JKey_FirstByteTs : aConnection.firstByteTimestamp ? aConnection.firstByteTimestamp : @(0),
                                     kRS_JKey_TransportProt : aRequest.URL.scheme,
                                     kRS_JKey_EdgeTransport : @"_"
                                     };
        
        return dataFromRequestsDictionary(aRequest, aResponse, dictionary);
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
    


}