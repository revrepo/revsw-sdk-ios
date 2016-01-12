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
    NSURL* url = newRequest.URL;
    if (url.host.length == 0)
    {
        url = [NSURL URLWithString:url.absoluteString relativeToURL:aBaseURL];
        if (url.host.length == 0)
        {
            return nil;
        }
    }
    
    NSString* host = url.host;
    NSString* sdkBaseHost = rs::NSStringFromStdString(rs::kRSRevBaseHost);
    NSString* scheme = url.scheme;

    if (![RSURLRequestProcessor isValidScheme:scheme])
        return nil;

    NSString* urlStr = [url absoluteString];
    BOOL isProvisioned                  = rs::Model::instance()->isDomainNameProvisioned(rs::stdStringFromNSString(host));
    NSString* sdkKey = rs::NSStringFromStdString(rs::Model::instance()->SDKKey());
    NSString* hostHeaderValue = nil;

    if (isProvisioned)
    {
        hostHeaderValue = host;
    }
    else
    {
        hostHeaderValue = [NSString stringWithFormat:@"%@.%@", sdkKey, sdkBaseHost];
        [newRequest setValue:host forHTTPHeaderField:rs::kRSRevHostHeader];
        [newRequest setValue:scheme forHTTPHeaderField:kRSRevMethodHeader];
    }
    
    [newRequest setValue:hostHeaderValue forHTTPHeaderField:kRSHostHeader];
    
    if (aIsEdge)
    {
        NSString* edgeHost = rs::NSStringFromStdString(rs::Model::instance()->edgeHost());
        NSRange range = [urlStr rangeOfString:host];
        
        urlStr = [urlStr stringByReplacingCharactersInRange:range withString:edgeHost];
    }
    
    if ([urlStr rangeOfString:@"https"].location != 0)
    {
        NSRange range = [urlStr rangeOfString:@"http"];
        if (range.location != 0)
        {
            return nil;
        }
        urlStr = [urlStr stringByReplacingCharactersInRange:range withString:@"https"];
    }
    
    url = [NSURL URLWithString:urlStr];
    [newRequest setURL:url];

    return newRequest;


//    NSString* hostHeader        = isProvisioned ? [NSString stringWithFormat:@"%@", transformedBaseHost] : [NSString stringWithFormat:@"%@.%@", transformedSDKKey, transformedBaseHost];
//    [newRequest setValue:hostHeader forHTTPHeaderField:kRSHostHeader];
//    [newRequest setValue:host forHTTPHeaderField:rs::kRSRevHostHeader];
    
//    NSString* urlStr = [URL absoluteString];
//    if (aIsEdge)
//    {
//        NSRange r = [[URL absoluteString] rangeOfString:host];
//
//        assert(r.location != NSNotFound);
//        urlStr = [[URL absoluteString] stringByReplacingCharactersInRange:r
//                                                                         withString:rs::kRSRevRedirectHost];
//    }
    
    
//    NSURLComponents* URLComponents = [NSURLComponents new];
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
//
//    NSString* urlStr = [URLComponents.URL absoluteString];
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
    
//    NSURL* newURL = [NSURL URLWithString:urlStr];
//    
//    [newRequest setURL:newURL];
//    [newRequest setHTTPBody:aRequest.HTTPBody];
//    [newRequest setHTTPMethod:aRequest.HTTPMethod];
    
//    return newRequest;
}

@end
