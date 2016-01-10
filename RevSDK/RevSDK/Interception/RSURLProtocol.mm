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
#import "RSURLConnectionNative.h"

@interface RSURLProtocol ()<RSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection* nativeConnection;
@property (nonatomic, strong) RSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* data;
@property (nonatomic, strong) RSURLConnectionNative* directConnection;
@property (nonatomic, copy)   NSURLResponse* response;

@end

@implementation RSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)aRequest
{
    if ([aRequest.URL.scheme isEqualToString:rs::kRSDataSchemeName])
    {
        return NO;
    }
    
    if (rs::Model::instance()->currentOperationMode() == rs::kRSOperationModeInnerOff)
    {
        return NO;
    }
    
    if (aRequest.isFileRequest)
    {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:rs::kRSURLProtocolHandledKey inRequest:aRequest])
    {
        return NO;
    }
    
    return YES;
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

- (BOOL)shouldRedirectRequest:(NSURLRequest *)aRequest
{
    NSURL* URL             = [aRequest URL];
    NSString* host         = [URL host];
    std::string domainName = rs::stdStringFromNSString(host);
    BOOL should            = rs::Model::instance()->shouldTransportDomainName(domainName);
    return should;
}

- (void)startLoading
{
    self.data = [NSMutableData data];
    
    if ([self shouldRedirectRequest:self.request])
    {
       self.connection = [RSURLConnection connectionWithRequest:self.request delegate:self];
      [self.connection start];
    }
    else
    {
        NSMutableURLRequest* newRequest = [self.request mutableCopy];
        [NSURLProtocol setProperty:@YES
                            forKey:rs::kRSURLProtocolHandledKey
                         inRequest:newRequest];
        
        self.directConnection = [[RSURLConnectionNative alloc] initWithRequest:newRequest delegate:self];
    }
}

- (void)stopLoading
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRSURLProtocolStoppedLoadingNotification
                                                        object:nil
                                                      userInfo:@{
                                                                 kRSDataKey : @([self.data length]),
                                                                 kRSResponseKey : self.response ? [self.response copy] : [NSHTTPURLResponse new]
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

#pragma mark -
#pragma mark - RSURLConnectionDelegate

- (void) rsconnection:(RSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"DID RECEIVE RESPONSE %@", response.URL);
    
    self.response = response;
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) rsconnection:(RSURLConnection *)aConnection didReceiveData:(NSData *)aData
{
    [self.data appendData:aData];
    [self.client URLProtocol:self didLoadData:aData];
}

- (void) rsconnectionDidFinishLoading:(RSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void) rsconnection:(RSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    __block BOOL flag = NO;
    dispatch_sync(dispatch_get_main_queue(), ^{
        flag = YES;
    });
}

#pragma mark - 
#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    __block BOOL flag = NO;
    dispatch_sync(dispatch_get_main_queue(), ^{
        flag = YES;
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)aData
{
    if (self.directConnection.firstByteTimestamp == nil)
    {
        NSDate* now                              = [NSDate date];
        NSTimeInterval interval                  = [now timeIntervalSince1970];
        int64_t timestamp                        = interval * 1000;
        self.directConnection.firstByteTimestamp = @(timestamp);
    }
    
    [self.data appendData:aData];
    [self.client URLProtocol:self didLoadData:aData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"DID RECEIVE RESPONSE %@", response.URL);
    
    self.response = response;
    
   [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (rs::Model::instance()->shouldCollectRequestsData())
    {
        self.directConnection.totalBytesReceived = @(self.data.length);
        NSDate* now                              = [NSDate date];
        NSTimeInterval interval                  = [now timeIntervalSince1970];
        int64_t timestamp                        = interval * 1000;
        self.directConnection.endTimestamp       = @(timestamp);
        
        NSHTTPURLResponse* response = (NSHTTPURLResponse *)self.response;
        rs::Data requestData        = rs::dataFromRequestAndResponse(self.directConnection.currentRequest, response, self.directConnection);
        rs::Model::instance()->addRequestData(requestData);
    }

    [self.client URLProtocolDidFinishLoading:self];
}

@end
