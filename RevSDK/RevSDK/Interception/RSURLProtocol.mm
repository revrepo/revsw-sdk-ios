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

@interface RSURLProtocol ()<RSURLConnectionDelegate, RSURLConnectionNativeDelegate>

@property (nonatomic, strong) RSURLConnection* connection;
@property (nonatomic, readwrite, assign) NSInteger dataLength;
@property (nonatomic, strong) RSURLConnectionNative* directConnection;

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
    self.dataLength = 0;
    
    if ([self shouldRedirectRequest:self.request])
    {
        NSString* dump = [NSString stringWithFormat:@"URL=%@, Method=%@, Headers:\n%@",
                          self.request.URL, self.request.HTTPMethod, self.request.allHTTPHeaderFields];
        rs::Log::info(rs::kLogTagSDKInerception, "Request %s", rs::stdStringFromNSString(dump).c_str());
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
        [self.directConnection start];
    }
}

- (void)stopLoading
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRSURLProtocolStoppedLoadingNotification
                                                        object:nil
                                                      userInfo:@{
                                                                 kRSDataKey : @(self.dataLength)
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
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*)response;
        NSString* dump = [NSString stringWithFormat:@"URL=%@, SFN=%@, Headers:\n%@",
                          response.URL, response.suggestedFilename, httpResp.allHeaderFields];
        rs::Log::info(rs::kLogTagSDKInerception, "Response %s", rs::stdStringFromNSString(dump).c_str());
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) rsconnection:(RSURLConnection *)aConnection didReceiveData:(NSData *)aData
{
    self.dataLength += aData.length;
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
#pragma mark - RSURLConnectionNativeDelegate

- (void)connection:(RSURLConnectionNative *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    __block BOOL flag = NO;
    dispatch_sync(dispatch_get_main_queue(), ^{
        flag = YES;
    });
}

- (void)connection:(RSURLConnectionNative *)connection didReceiveData:(NSData *)aData
{
    //[self.data appendData:aData];
    self.dataLength += aData.length;
    [self.client URLProtocol:self didLoadData:aData];
}

- (void)connection:(RSURLConnectionNative *)connection didReceiveResponse:(NSURLResponse *)response
{
   [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connectionDidFinish:(RSURLConnectionNative *)connection
{
    if (rs::Model::instance()->shouldCollectRequestsData())
    {
        self.directConnection.totalBytesReceived = @(self.dataLength);
        rs::Data requestData                     = rs::dataFromConnection(self.directConnection, NO);
        rs::Model::instance()->addRequestData(requestData);
    }

    [self.client URLProtocolDidFinishLoading:self];
}

@end
