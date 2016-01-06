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

@interface RSURLProtocol ()<RSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection* nativeConnection;
@property (nonatomic, strong) RSURLConnection* connection;
@property (nonatomic, strong) NSMutableData* data;
@property (nonatomic, strong) NSURLConnection* directConnection;

@end

@implementation RSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)aRequest
{
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
    
    NSLog(@"CAN INIT WITH REQUEST %@", aRequest);
    
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
        NSLog(@"SHOULD REDIRECT %@", self.request);
        
       self.connection = [RSURLConnection connectionWithRequest:self.request delegate:self];
      [self.connection start];
    }
    else
    {
        NSLog(@"SHOULD NOT REDIRECT %@", self.request);
        
        NSMutableURLRequest* newRequest = [self.request mutableCopy];
        [NSURLProtocol setProperty:@YES
                            forKey:rs::kRSURLProtocolHandledKey
                         inRequest:newRequest];
        
        self.directConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
    }
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

#pragma mark -
#pragma mark - RSURLConnectionDelegate

- (void) rsconnection:(RSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
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

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response != nil)
    {
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

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
    [self.data appendData:aData];
    [self.client URLProtocol:self didLoadData:aData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Request %@ Response %@", self.request, self.cachedResponse.response);
    
    [self.client URLProtocolDidFinishLoading:self];
}

@end
