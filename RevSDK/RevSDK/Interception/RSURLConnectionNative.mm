//
//  RSURLConnectionNative.m
//  RevSDK
//
//  Created by Andrey Chernukha on 1/6/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

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

@end
