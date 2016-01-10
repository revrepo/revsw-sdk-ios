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
#import "RSLog.h"

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

+ (NSMutableURLRequest *)proccessRequest:(NSURLRequest *)aRequest isEdge:(BOOL)aIsEdge baseURL:(NSURL*)aBaseURL
{
    if ([aRequest.URL.scheme isEqualToString:rs::kRSDataSchemeName])
    {
        rs::Log::info(rs::kLogTagSTDRequest, "Data scheme is being used");
    }
    
    NSMutableURLRequest* newRequest     = [aRequest mutableCopy];
    NSURL* URL                          = aRequest.URL;
    NSString* host                      = URL.host;
    if (host == nil)
    {
        if (aBaseURL == nil)
            return nil;
        
        URL = [[NSURL alloc] initFileURLWithPath:URL.absoluteString relativeToURL:aBaseURL];
        if (URL == nil)
            return nil;
        
        host = URL.host;
        if (host == nil)
            return nil;
    }
    //NSLog(@"Bofore: %@", URL.absoluteString);
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
    
//    NSString* urlStr = [URL absoluteString];
//    if (aIsEdge)
//    {
//        NSRange r = [[URL absoluteString] rangeOfString:host];
//
//        assert(r.location != NSNotFound);
//        urlStr = [[URL absoluteString] stringByReplacingCharactersInRange:r
//                                                                         withString:rs::kRSRevRedirectHost];
//    }
    
    
    NSURLComponents* URLComponents = [NSURLComponents new];
//    if (aIsEdge)
//    {
//        URLComponents.host         = rs::kRSRevRedirectHost;
//    }
//    else
//    {
//        URLComponents.host         = originalComponents.host;
//    }
//    URLComponents.scheme           = scheme;
//    URLComponents.path             = URL.path;
//    URLComponents.queryItems       = originalComponents.queryItems;
    
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

    NSString* urlStr = [URLComponents.URL absoluteString];
    //NSLog(@"After: %@", urlStr);
//    NSMutableString* urlPath = [urlStr mutableCopy];
//    if ([[URL absoluteString] hasSuffix:@"/"] && ![urlPath hasSuffix:@"/"])
//    {
//        [urlPath appendString:@"/"];
//    }

//    NSMutableString* urlPath = [urlStr mutableCopy];
//    if ([[URL absoluteString] hasSuffix:@"/"] && ![urlPath hasSuffix:@"/"])
//    {
//        [urlPath appendString:@"/"];
//    }
    
    NSURL* newURL = [NSURL URLWithString:urlStr];
    
    [newRequest setURL:newURL];
    [newRequest setHTTPBody:aRequest.HTTPBody];
    [newRequest setHTTPMethod:aRequest.HTTPMethod];
    
    return newRequest;
}

@end
