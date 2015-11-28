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

static NSString* const kRSHostHeader = @"Host";
static NSString* const kRSRevHostHeader = @"X-Rev-Host";

@implementation RSURLRequestProcessor

+ (NSURLRequest *)proccessRequest:(NSURLRequest *)aRequest
{
    NSMutableURLRequest* newRequest = [NSMutableURLRequest new];
    NSURL* URL                      = aRequest.URL;
    NSString* host                  = URL.host;
    std::string  stdHost            = rs::stdStringFromNSString(host);
    BOOL isProvisioned              = rs::Model::instance()->isDomainNameProvisioned(stdHost);
    std::string edgeHost            = rs::Model::instance()->edgeHost();
    NSString* transformedEdgeHost   = rs::NSStringFromStdString(edgeHost);
    NSString* scheme                = URL.scheme;
    
    if (isProvisioned)
    {
        [newRequest addValue:host forHTTPHeaderField:kRSHostHeader];
    }
    else
    {
        
        scheme                      = rs::NSStringFromStdString(rs::kRSHTTPSProtocolName);
        std::string SDKKey          = rs::Model::instance()->SDKKey();
        NSString* transformedSDKKey = rs::NSStringFromStdString(SDKKey);
        NSString* hostHeader        = [NSString stringWithFormat:@"%@.%@", transformedSDKKey, transformedEdgeHost];
        
        [newRequest addValue:hostHeader forHTTPHeaderField:kRSHostHeader];
        [newRequest addValue:host forHTTPHeaderField:kRSRevHostHeader];
    }
    
    NSURLComponents* URLComponents = [NSURLComponents new];
    URLComponents.host             = transformedEdgeHost;
    URLComponents.scheme           = scheme;
    NSURL* newURL                  = URLComponents.URL;
    
    [newRequest setURL:newURL];
    [newRequest setHTTPMethod:aRequest.HTTPMethod];
    [newRequest setHTTPBody:aRequest.HTTPBody];
    
    return aRequest;
}

@end
