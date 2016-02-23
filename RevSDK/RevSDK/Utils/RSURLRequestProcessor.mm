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
    //11.02.16 Perepelitsa remove kRSRevBaseHostto config parameter
    //NSString* sdkBaseHost = rs::NSStringFromStdString(rs::kRSRevBaseHost);
    NSString* sdkBaseHost = rs::NSStringFromStdString(rs::Model::instance()->revBaseHost());
    //
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
        
        if (!isProvisioned)
        {
           urlStr = [urlStr stringByReplacingCharactersInRange:range withString:@"https"];
        }
    }
    
    url = [NSURL URLWithString:urlStr];
    [newRequest setURL:url];

    return newRequest;
}

@end
