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

namespace rs
{
    class Request;
    
    extern NSString* const kRSURLProtocolHandledKey;
    
    //protocols
    extern const std::string kRSHTTPSProtocolName;
    
    std::string stdStringFromNSString(NSString *aNSString);
    NSString* nsStringFromStdString(std::string aStdString);
    
    std::shared_ptr<Request> requestFromURLRequest(NSURLRequest *aURLRequest);
    NSURLRequest* URLRequestFromRequest(std::shared_ptr<Request> aRequest);
}
#endif