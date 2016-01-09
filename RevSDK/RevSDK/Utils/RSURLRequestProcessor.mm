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
#import "Utils.hpp"

#include <string>

static NSString* const kRSNonVPNURL = @"https://rev-200.revdn.net";
static NSString* const kRSVPNURL = @"http://testsjc20-bp01.revsw.net/";

static NSString* const kRSHostHeader = @"Host";
static NSString* const kRSRevMethodHeader = @"X-Rev-Proto";

@implementation RSURLRequestProcessor

+ (BOOL)isValidScheme:(NSString*)aScheme
{
    if (aScheme == nil)
        return NO;
    
    return [@[@"http", @"https"] indexOfObject:aScheme] != NSNotFound;
}

+ (NSURLRequest *)proccessRequest:(NSURLRequest *)aRequest isEdge:(BOOL)aIsEdge
{
    NSMutableURLRequest* newRequest     = [aRequest mutableCopy];
    NSURL* URL                          = aRequest.URL;
    NSString* host                      = URL.host;
    std::string  stdHost                = rs::stdStringFromNSString(host);
    BOOL isProvisioned                  = rs::Model::instance()->isDomainNameProvisioned(stdHost);
    NSString* transformedBaseHost       = rs::NSStringFromStdString(rs::kRSRevBaseHost);
    NSString* scheme                    = URL.scheme;
    NSURLComponents* originalComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    
    if ([RSURLRequestProcessor isValidScheme:scheme])
        [newRequest setValue:scheme forHTTPHeaderField:kRSRevMethodHeader];
    
    scheme                      = rs::kRSHTTPSProtocolName;
    std::string SDKKey          = rs::Model::instance()->SDKKey();
    NSString* transformedSDKKey = rs::NSStringFromStdString(SDKKey);
    NSString* hostHeader        = isProvisioned ? [NSString stringWithFormat:@"%@", transformedBaseHost] : [NSString stringWithFormat:@"%@.%@", transformedSDKKey, transformedBaseHost];
    [newRequest setValue:hostHeader forHTTPHeaderField:kRSHostHeader];
    [newRequest setValue:host forHTTPHeaderField:rs::kRSRevHostHeader];
    
    NSURLComponents* URLComponents = [NSURLComponents new];
    if (aIsEdge)
    {
        URLComponents.host         = rs::kRSRevRedirectHost;
    }
    else
    {
        URLComponents.host         = originalComponents.host;
    }
    URLComponents.scheme           = scheme;
    URLComponents.path             = URL.path;
    URLComponents.queryItems       = originalComponents.queryItems;

    NSMutableString* urlPath = [[URLComponents.URL absoluteString] mutableCopy];
    if ([[URL absoluteString] hasSuffix:@"/"] && ![urlPath hasSuffix:@"/"])
    {
        [urlPath appendString:@"/"];
    }
    
    NSURL* newURL = [NSURL URLWithString:urlPath];
    
    [newRequest setURL:newURL];
    [newRequest setHTTPBody:aRequest.HTTPBody];
    [newRequest setHTTPMethod:aRequest.HTTPMethod];
    
    return newRequest;
}

@end
