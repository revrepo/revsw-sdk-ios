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

#import "Model.hpp"

@interface NSURLRequest (FileRequest)

@property (nonatomic, readonly) BOOL isFileRequest;

@end

@implementation NSURLRequest(FileRequest)

- (BOOL)isFileRequest
{
    return self.URL && self.URL.isFileURL;
}

@end

@interface RSURLProtocol ()<RSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection* nativeConnection;
@property (nonatomic, strong) RSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* data;

@end

@implementation RSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)aRequest
{
    NSURL* URL             = [aRequest URL];
    NSString* host         = [URL host];
    std::string domainName = rs::stdStringFromNSString(host);
    BOOL can               = rs::Model::instance()->shouldTransportDomainName(domainName) &&
                             ![NSURLProtocol propertyForKey:rs::kRSURLProtocolHandledKey inRequest:aRequest] &&
                             !aRequest.isFileRequest;
    return can;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)aTask
{
    NSURLRequest* request = [aTask currentRequest];

    return [self canInitWithRequest:request];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)aRequest
{
    return aRequest;
}

- (void)startLoading
{
    self.data = [NSMutableData data];

    self.connection = [RSURLConnection connectionWithRequest:self.request delegate:self];
    [self.connection start];
}

- (void)stopLoading
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kRSURLProtocolStoppedLoading"
                                                        object:nil
                                                      userInfo:@{
                                                                 @"kRSDataKey" : @([self.data length])
                                                                 }];
}

- (NSCachedURLResponse *)cachedResponse
{
    return nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
}

- (void) rs_connection:(RSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) rs_connection:(RSURLConnection *)aConnection didReceiveData:(NSData *)aData
{
    [self.data appendData:aData];
    [self.client URLProtocol:self didLoadData:aData];
}

- (void) rs_connectionDidFinishLoading:(RSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void) rs_connection:(RSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
}

@end
