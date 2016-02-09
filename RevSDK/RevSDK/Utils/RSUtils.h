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

#ifndef RSUTILS_H
#define RSUTILS_H

#import <Foundation/Foundation.h>

#include <memory>
#include <iostream>
#include <string>
#include <map>
#include <vector>

#import "RSPublicConsts.h"

#define RSTimeStamp ((long long)([[NSDate date] timeIntervalSince1970] * 1000))

@class RSURLConnectionNative;

@interface NSURLRequest (FileRequest)

@property (nonatomic, readonly) BOOL isFileRequest;

@end

@interface NSURLRequest (CDescription)

- (const char*)cDescription;

@end

@interface NSHTTPURLResponse (CDescription)

- (const char*)cDescription;

@end

namespace rs
{
    class Request;
    class Response;
    class Data;
    class Error;
    class Configuration;
    class Connection;
    
    //version
    extern const int kRSSDKVersion;
    
    // Rev Host
    extern const std::string kRSRevBaseHost;
    extern NSString* const kRSRevHostHeader;
    extern NSString* const kRSRevLoadConfigurationHost;
    
    //codes
    extern const long kRSNoErrorCode;
    extern const long kRSErrorCodeConfigurationNotValid;
    
    //notifications
    extern NSString* const kRSURLProtocolDidReceiveDataNotification;
    extern NSString* const kRSURLProtocolDidReceiveResponseNotification;
    
    //keys
    extern NSString* const kRSURLProtocolHandledKey;
    extern NSString* const kRSConfigurationStorageKey;
    extern NSString* const kRSRequestDataStorageKey;
    extern NSString* const kRSLastMileDataStorageKey;
    extern NSString* const kRSEventsDataStorageKey;
    extern NSString* const kRSOSKey;
    extern NSString* const kRSAppNameKey;
    extern NSString* const kRSSDKReleaseVersionKey;
    extern NSString* const kRSConfigurationApiURLKey;
    extern NSString* const kRSConfigurationRefreshIntervalKey;
    extern NSString* const kRSConfigurationStaleTimeoutKey;
    extern NSString* const kRSEdgeHostKey;
    extern NSString* const kRSOperationModeKey;
    extern NSString* const kRSAllowedTransportProtocolsKey;
    extern NSString* const kRSInitialTransportProtocolsKey;
    extern NSString* const kRSTransportMonitoringURLKey;
    extern NSString* const kRSStatsReportingURLKey;
    extern NSString* const kRSStatsReportingIntervalKey;
    extern NSString* const kRSStatsReportingLevelKey;
    extern NSString* const kRSStatsReportingMaxRequestsKey;
    extern NSString* const kRSDomainsProvisionedListKey;
    extern NSString* const kRSDomainsWhiteListKey;
    extern NSString* const kRSDomainsBlackListKey;
    extern NSString* const kRSLoggingLevelKey;
    extern NSString* const kRSConfigsKey;
    
    //fields
    extern NSString*  const kRSiOSField;
    
    //protocols
    extern NSString* const kRSHTTPSProtocolName;
    extern NSString* const kRSQUICProtocolName;
    extern NSString* const kRSStandardProtocolName;
    extern NSString* const kRSRevProtocolName;
    extern NSString* const kRSDataSchemeName;
    extern NSString* const kRSMoatBridgeSchemeName;
    
    // log levels
    extern NSString* const kRSLogLevelNone;
    extern NSString* const kRSLogLevelDebug;
    extern NSString* const kRSLogLevelError;
    extern NSString* const kRSLogLevelInfo;
    
    //operation mode strings
    extern NSString* const kRSOperationModeOffString;
    extern NSString* const kRSOperationModeTransferString;
    extern NSString* const kRSOperationModeReportString;
    extern NSString* const kRSOperationModeTransferReportString;
    
    Configuration configurationFromNSDictionary(NSDictionary* aDictionary);
    NSDictionary* NSDictionaryFromConfiguration(const Configuration&);
    
    std::string stdStringFromNSString(NSString *aNSString);
    NSString* NSStringFromStdString(std::string aStdString);
    
    std::map <std::string, std::string> stdMapFromNSDictionary(NSDictionary* aDictionary);
    NSDictionary* NSDictionaryFromStdMap(std::map<std::string, std::string> aMap);
    
    std::vector<std::string> vectorFromNSArray(NSArray<NSString*> * aArray);
    NSArray<NSString*> * NSArrayFromVector(std::vector<std::string> aVector);
    
    Data dataFromNSData(NSData* aData);
    NSData* NSDataFromData(Data aData);
    
    std::shared_ptr<Request> requestFromURLRequest(NSURLRequest* aURLRequest);
    NSMutableURLRequest* URLRequestFromRequest(std::shared_ptr<Request> aRequest);
    
    std::shared_ptr<Response> responseFromHTTPURLResponse(NSHTTPURLResponse* aHTTPURLResponse);
    NSHTTPURLResponse* NSHTTPURLResponseFromResponse(std::shared_ptr<Response>);
    
    Error errorFromNSError(NSError* aError);
    NSError* NSErrorFromError(Error aError);
    
    std::string _loadConfigurationURL(const std::string&);
    
    std::vector<Data> dataNSArrayToStdVector(NSArray *);
    
    Data dataFromRequestAndResponse(NSURLRequest*, NSHTTPURLResponse*, Connection*, NSString*, BOOL);
    Data dataFromConnection( RSURLConnectionNative*, BOOL);
    
    bool _isValidURL(NSString* aURLString);
    bool _isValidConfiguration(const Data&, Error*);
    bool _internetConnectionAvailable();
    bool _areDomainNamesEqual(NSString*, NSString*);
    bool _isApplicationActive();
    void _postNotification(NSString*);
}
#endif












