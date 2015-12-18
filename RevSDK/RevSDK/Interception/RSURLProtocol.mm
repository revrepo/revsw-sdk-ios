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
#import "RSURLRequestProcessor.h"
#import "Model.hpp"

@interface RSURLProtocol ()<RSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection* nativeConnection;
@property (nonatomic, strong) RSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* data;

@end

@implementation RSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)aRequest
{
    return !aRequest.isFileRequest;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)aTask
{
    NSURLRequest* request = [aTask originalRequest];
    return [self canInitWithRequest:request];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)aRequest
{
    return aRequest;
}

- (void)startLoading
{
    self.data       = [NSMutableData data];
    self.connection = [RSURLConnection connectionWithRequest:self.request delegate:self];
    [self.connection start];
}

- (void)stopLoading
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRSURLProtocolStoppedLoadingNotification
                                                        object:nil
                                                      userInfo:@{
                                                                 kRSDataKey : @([self.data length])
                                                                 }];
}

- (NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

- (id)initWithTask:(NSURLSessionTask *)task cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    NSURLRequest* request = [task originalRequest];
    
    self = [self initWithRequest:request cachedResponse:cachedResponse client:client];
    
    return self;
}

- (void) connection:(RSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) connection:(RSURLConnection *)aConnection didReceiveData:(NSData *)aData
{
    [self.data appendData:aData];
    [self.client URLProtocol:self didLoadData:aData];
}

- (void) connectionDidFinishLoading:(RSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void) connection:(RSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
}

@end
