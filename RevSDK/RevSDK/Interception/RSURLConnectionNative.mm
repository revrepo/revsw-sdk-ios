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

#import "RSURLConnectionNative.h"
#import "Connection.hpp"
#import "RSOriginSession.h"

@implementation RSURLConnectionNative

- (instancetype)initWithRequest:(NSURLRequest *)aRequest delegate:(id<RSURLConnectionNativeDelegate>)aDelegate
{
    self = [super init];
    
    if (self)
    {
        int connectionId        = rs::Connection::getLastConnectionId();
        _connectionId           = @(connectionId);
        _request                = aRequest;
        _delegate               = aDelegate;
    }
    
    return self;
}

- (void)start
{
    NSDate* now             = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSince1970];
    int64_t timestamp       = interval * 1000;
    self.startTimestamp     = @(timestamp);
    
//    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession* session                    = [NSURLSession sessionWithConfiguration:configuration
//                                                                             delegate:self
//                                                                        delegateQueue:[NSOperationQueue currentQueue]];
//    
//    NSURLSessionTask* task = [session dataTaskWithRequest:self.request];
//    [task resume];
    
    [[RSOriginSession instance] createTaskWithRequest:self.request
                                             delegate:self];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSDate* now             = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSince1970];
    int64_t timestamp       = interval * 1000;
    self.endTimestamp       = @(timestamp);
    
    if (error)
    {
       [self.delegate connection:self didFailWithError:error];
    }
    else
    {
        [self.delegate connectionDidFinish:self];
    }
//    [session invalidateAndCancel];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.delegate connection:self didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSDate* now             = [NSDate date];
    NSTimeInterval interval = [now timeIntervalSince1970];
    int64_t timestamp       = interval * 1000;
    self.firstByteTimestamp = @(timestamp);
    self.response           = (NSHTTPURLResponse*)response;
    
    [self.delegate connection:self didReceiveResponse:response];
    
    if (completionHandler)
        completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    [self.delegate connection:self
       wasRedirectedToRequest:request
             redirectResponse:response];
}

@end
