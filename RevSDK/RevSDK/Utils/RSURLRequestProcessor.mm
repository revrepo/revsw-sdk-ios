//
//  RSURLRequestProcessor.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/27/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSURLRequestProcessor.h"

#import "Model.hpp"
#import "RSUtils.h"

#include <string>

static NSString* const kRSNonVPNURL = @"https://rev-200.revdn.net";
static NSString* const kRSVPNURL = @"http://testsjc20-bp01.revsw.net/";

static NSString* const kRSHostHeader = @"Host";
static NSString* const kRSRevHostHeader = @"X-Rev-Host";

@implementation RSURLRequestProcessor

+ (NSURLRequest *)proccessRequest:(NSURLRequest *)aRequest
{
    NSMutableURLRequest* newRequest     = [aRequest mutableCopy];
    NSURL* URL                          = aRequest.URL;
    NSString* host                      = URL.host;
    std::string  stdHost                = rs::stdStringFromNSString(host);
    BOOL isProvisioned                  = rs::Model::instance()->isDomainNameProvisioned(stdHost);
    NSString* transformedBaseHost       = rs::NSStringFromStdString(rs::kRSRevBaseHost);
    NSString* scheme                    = URL.scheme;
    NSURLComponents* originalComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    
    if (isProvisioned)
    {
        [newRequest addValue:host forHTTPHeaderField:kRSHostHeader];
    }
    else
    {
        scheme                      = rs::NSStringFromStdString(rs::kRSHTTPSProtocolName);
        std::string SDKKey          = rs::Model::instance()->SDKKey();
        NSString* transformedSDKKey = rs::NSStringFromStdString(SDKKey);
        NSString* hostHeader        = [NSString stringWithFormat:@"%@.%@", transformedSDKKey, transformedBaseHost];
        [newRequest setValue:hostHeader forHTTPHeaderField:kRSHostHeader];
        [newRequest setValue:host forHTTPHeaderField:kRSRevHostHeader];
    }
    
    NSURLComponents* URLComponents = [NSURLComponents new];
    URLComponents.host             = rs::kRSRevRedirectHost;
    URLComponents.scheme           = scheme;
    URLComponents.path             = URL.path;
    URLComponents.queryItems       = originalComponents.queryItems;
    
    [newRequest setURL:URLComponents.URL];
    [newRequest setHTTPBody:aRequest.HTTPBody];
    [newRequest setHTTPMethod:aRequest.HTTPMethod];
    
    return newRequest;
}

@end
