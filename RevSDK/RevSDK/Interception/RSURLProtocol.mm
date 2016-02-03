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
    rs::Log::info(rs::kLogTagRequestTracking, ("Request entered protocol " + [aRequest StdDescription]).c_str());
    
    NSURL* requestrURL = aRequest.URL;
    NSString* host     = requestrURL.host;
    NSString* scheme   = [requestrURL.scheme lowercaseString];
    
    BOOL hasHost = host.length > 0;
    
    if (!hasHost)
    {
        return NO;
    }

    BOOL isHTTPorHTTPS = [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"];
    if (!isHTTPorHTTPS)
    {
        return NO;
    }
    
    if (aRequest.isFileRequest)
    {
        return NO;
    }

    if (rs::Model::instance()->currentOperationMode() == rs::kRSOperationModeInnerOff)
    {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:rs::kRSURLProtocolHandledKey inRequest:aRequest])
    {
        return NO;
    }
    
    rs::Log::info(rs::kLogTagRequestTracking, ("Request passed " + [aRequest StdDescription]).c_str());
    
    return YES;
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
        rs::Log::info(rs::kLogTagRequestTracking, ("Start loading origin " + [self.request StdDescription]).c_str());
        
        NSString* dump = [NSString stringWithFormat:@"URL=%@, Method=%@, Headers:\n%@",
                          self.request.URL, self.request.HTTPMethod, self.request.allHTTPHeaderFields];
        rs::Log::info(rs::kLogTagSDKInerception, "Request %s", rs::stdStringFromNSString(dump).c_str());
        self.connection = [RSURLConnection connectionWithRequest:self.request delegate:self];
        [self.connection start];
    }
    else
    {
        rs::Log::info(rs::kLogTagRequestTracking, ("Start loading REV " + [self.request StdDescription]).c_str());
        
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
   rs::Log::info(rs::kLogTagRequestTracking, ("Stop loading " + [self.request StdDescription]).c_str());
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
    NSURLRequest* request = [task currentRequest];
    
    self = [self initWithRequest:request cachedResponse:cachedResponse client:client];
    
    return self;
}

#pragma mark -
#pragma mark - RSURLConnectionDelegate

- (void)rsconnection:(RSURLConnection *)connection wasRedirectedToRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    rs::Log::info(rs::kLogTagRequestTracking, ("REV redirect request " +  [request StdDescription] + " response " + [response StdDescription]).c_str());
    
    NSMutableURLRequest* newRequest = [request mutableCopy];
    
    [NSURLProtocol removePropertyForKey:rs::kRSURLProtocolHandledKey
                              inRequest:newRequest];
    
    [self.client URLProtocol:self
      wasRedirectedToRequest:newRequest
            redirectResponse:response];
}

- (void) rsconnection:(RSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:rs::kRSURLProtocolDidReceiveResponseNotification
                                                        object:nil];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:rs::kRSURLProtocolDidReceiveDataNotification
                                                        object:nil];
    
    self.dataLength += aData.length;
    [self.client URLProtocol:self didLoadData:aData];
}

- (void) rsconnectionDidFinishLoading:(RSURLConnection *)connection
{
    rs::Log::info(rs::kLogTagRequestTracking, ("REV protocol did finish" + [self.request StdDescription]).c_str());
    [self.client URLProtocolDidFinishLoading:self];
}

- (void) rsconnection:(RSURLConnection *)connection didFailWithError:(NSError *)error
{
    rs::Log::error(rs::kLogTagRequestTracking, ("REV protocol did fail " + [self.request StdDescription] + [error StdDescription]).c_str());
    
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
     rs::Log::error(rs::kLogTagRequestTracking, ("Origin protocol did fail " + [self.request StdDescription] + [error StdDescription]).c_str());
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)connection:(RSURLConnectionNative *)connection didReceiveData:(NSData *)aData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:rs::kRSURLProtocolDidReceiveDataNotification
                                                        object:nil];
    self.dataLength += aData.length;
    [self.client URLProtocol:self didLoadData:aData];
}

- (void)connection:(RSURLConnectionNative *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[NSNotificationCenter defaultCenter] postNotificationName:rs::kRSURLProtocolDidReceiveResponseNotification
                                                        object:nil];
    
   [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connectionDidFinish:(RSURLConnectionNative *)connection
{
    rs::Log::info(rs::kLogTagRequestTracking, ("Origin protocol did finish" + [self.request StdDescription]).c_str());
    
    if (rs::Model::instance()->shouldCollectRequestsData())
    {
        self.directConnection.totalBytesReceived = @(self.dataLength);
        rs::Data requestData                     = rs::dataFromConnection(self.directConnection, NO);
        rs::Model::instance()->addRequestData(requestData);
    }

    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(RSURLConnectionNative *)aConnection wasRedirectedToRequest:(NSURLRequest *)aRequest redirectResponse:(NSURLResponse *)aResponse
{
    rs::Log::info(rs::kLogTagRequestTracking, ("Origin protcol redirect request " +  [aRequest StdDescription] + " response " + [aResponse StdDescription]).c_str());
    NSMutableURLRequest* newRequest = [aRequest mutableCopy];
    
    [NSURLProtocol removePropertyForKey:rs::kRSURLProtocolHandledKey
                              inRequest:newRequest];
    
    [self.client URLProtocol:self
      wasRedirectedToRequest:newRequest
            redirectResponse:aResponse];
}

@end
