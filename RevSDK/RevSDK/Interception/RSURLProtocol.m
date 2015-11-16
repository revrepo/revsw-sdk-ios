//
//  RVURLProtocol.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSURLProtocol.h"
#import "RSUtils.h"

@implementation RSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return ![NSURLProtocol propertyForKey:kRVURLProtocolHandledKey inRequest:request];
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task
{
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSLog(@"Start loading");
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:kRVURLProtocolHandledKey inRequest:newRequest];
}

- (void)stopLoading
{
    
}

@end
