//
//  Utils.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef RSUTILS_H
#define RSUTILS_H

#import <Foundation/Foundation.h>

#include <memory>
#include <iostream>
#include <string>
#include <map>
#include <vector>

#import "RSPublicConsts.h"

namespace rs
{
    class Request;
    class Response;
    class Data;
    class Error;
    class Configuration;
    
    // Rev Host
    extern const std::string kRSRevBaseHost;
    extern NSString* const kRSRevRedirectHost;
    
    //codes
    extern const long kRSNoErrorCode;
    
    //keys
    extern NSString* const kRSURLProtocolHandledKey;
    extern const std::string kRSErrorDescriptionKey;
    extern NSString* const kRSConfigurationStorageKey;
    extern NSString* const kRSRequestDataStorageKey;
    
    //protocols
    extern const std::string kRSHTTPSProtocolName;
    
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
    NSURLRequest* URLRequestFromRequest(std::shared_ptr<Request> aRequest);
    
    std::shared_ptr<Response> responseFromHTTPURLResponse(NSHTTPURLResponse* aHTTPURLResponse);
    NSHTTPURLResponse* NSHTTPURLResponseFromResponse(std::shared_ptr<Response>);
    
    Error errorFromNSError(NSError* aError);
    NSError* NSErrorFromError(Error aError);
    
    std::string loadConfigurationURL();
    std::string reportStatsURL();
    
    std::vector<Data> dataNSArrayToStdVector(NSArray *);
    
    Data dataFromRequestAndResponse(NSURLRequest*, NSHTTPURLResponse*);
}
#endif