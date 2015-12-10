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

@interface NSURLRequest (FileRequest)

@property (nonatomic, readonly) BOOL isFileRequest;

@end

@implementation NSURLRequest(FileRequest)

- (BOOL)isFileRequest
{
    return self.URL && self.URL.isFileURL;
}

@end

@interface RSURLProtocol ()<RSURLConnectionDelegate>

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
    BOOL testPassOptionOn    = rs::Model::instance()->testPassOption();
    NSURLRequest* newRequest = (aRequest.URL.host && !testPassOptionOn) ? [RSURLRequestProcessor proccessRequest:aRequest] : aRequest;
    return newRequest;
}

- (void)startLoading
{
    self.data       = [NSMutableData data];
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
