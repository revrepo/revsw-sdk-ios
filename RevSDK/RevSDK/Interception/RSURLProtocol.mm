//
//  RVURLProtocol.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSUtils.h"

#import "RSURLProtocol.h"
#import "RSURLConnection.h"

@interface RSURLProtocol ()<RSURLConnectionDelegate>

@property (nonatomic, strong) RSURLConnection* connection;

@end

@implementation RSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return ![NSURLProtocol propertyForKey:rs::kRSURLProtocolHandledKey inRequest:request];
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
    [NSURLProtocol setProperty:@YES forKey:rs::kRSURLProtocolHandledKey inRequest:newRequest];
    
    self.connection = [RSURLConnection connectionWithRequest:newRequest delegate:self];
    [self.connection start];
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
    NSLog(@"Stop loading");
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(RSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) connection:(RSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void) connectionDidFinishLoading:(RSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(RSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
}


@end
