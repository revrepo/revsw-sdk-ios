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

@interface RSURLProtocol ()<RSURLConnectionDelegate>

@property (nonatomic, strong) RSURLConnection* connection;

@end

@implementation RSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)aRequest
{
    NSURL* URL             = [aRequest URL];
    NSString* host         = [URL host];
    std::string domainName = rs::stdStringFromNSString(host);
    
    return rs::Model::instance()->shouldTransportDomainName(domainName) &&
           ![NSURLProtocol propertyForKey:rs::kRSURLProtocolHandledKey inRequest:aRequest] &&
           !aRequest.isFileRequest;
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
    self.connection = [RSURLConnection connectionWithRequest:self.request delegate:self];
    [self.connection start];
}

- (void)stopLoading
{
   
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
