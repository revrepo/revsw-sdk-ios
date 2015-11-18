//
//  Utils.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSUtils.h"
#include "Request.hpp"

namespace rs
{
    NSString* const kRSURLProtocolHandledKey = @"kRVProtocolHandledKey";
 
    //protocols
    const std::string kRSHTTPSProtocolName = "https";
    
    std::string stdStringFromNSString(NSString* aNSString)
    {
        return std::string([aNSString UTF8String]);
    }
    
    NSString* nsStringFromStdString(std::string aStdString)
    {
        return [NSString stringWithUTF8String:aStdString.c_str()];
    }
    
    std::shared_ptr<Request> requestFromURLRequest(NSURLRequest* aURLRequest)
    {
        std::string URLString = stdStringFromNSString(aURLRequest.URL.absoluteString);
        std::shared_ptr<Request> request = std::make_shared<Request>(URLString);
        return request;
    }
    
    NSURLRequest* URLRequestFromRequest(std::shared_ptr<Request> aRequest)
    {
        NSString* URLString = nsStringFromStdString(aRequest.get()->URL());
        NSURL* URL          = [NSURL URLWithString:URLString];
        return [NSURLRequest requestWithURL:URL];
    }
}