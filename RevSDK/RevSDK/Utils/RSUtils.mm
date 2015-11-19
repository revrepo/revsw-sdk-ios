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

namespace rs
{
    NSString* const kRSURLProtocolHandledKey = @"kRVProtocolHandledKey";
 
    //protocols
    const std::string kRSHTTPSProtocolName = "https";
    
    std::string stdStringFromNSString(NSString* aNSString)
    {
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
            NSCAssert([value isKindOfClass:[NSString class]], @"Value is not a string %@", value);
            
            std::string std_key   = stdStringFromNSString(key);
            std::string std_value = stdStringFromNSString(value);
            map[std_key]          = std_value;
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
}