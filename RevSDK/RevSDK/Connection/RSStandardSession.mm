//
//  StandardSession.m
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/9/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import "RSStandardSession.h"
#import "RSURLRequestProcessor.h"
#import "RSUtils.h"
#include "Model.hpp"

#include <unordered_map>

@interface RSStandardSession()<NSURLSessionDataDelegate>
{
    std::unordered_map<int, std::shared_ptr<rs::Connection>> mConnections;
    NSLock* mLock;
}

@property (nonatomic, readwrite, strong) NSURLSessionConfiguration* configuration;
@property (nonatomic, readwrite, strong) NSURLSession* session;

@end

@implementation RSStandardSession

+ (RSStandardSession*)instance
{
    static dispatch_once_t pred = 0;
    __strong static RSStandardSession* mInstance = nil;
    
    dispatch_once(&pred, ^
    {
        if ([[NSThread currentThread] isMainThread])
        {
            mInstance = [[self alloc] init];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                mInstance = [[self alloc] init];
            });
        }
    });
    
    return mInstance;
}

- (id)init
{
    if (self = [super init])
    {
        self.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        self.session = [NSURLSession sessionWithConfiguration:self.configuration
                                                     delegate:self
                                                delegateQueue:nil];
        
        mLock = [[NSLock alloc] init];
    }
    return self;
}

- (NSURLSessionTask*)createTaskWithRequest:(NSURLRequest*)aRequest
                                connection:(std::shared_ptr<rs::Connection>)aConnection
{
    if (aRequest == nil || aConnection.get() == nullptr)
        return nil;
    
    __block NSURLSessionTask* task = nil;
    
    dispatch_block_t block = ^() {
        
        task = [self.session dataTaskWithRequest:aRequest];
        task.taskDescription = [NSString stringWithFormat:@"%d", aConnection->getID()];
        
        [mLock lock];
        mConnections[aConnection->getID()] = aConnection;
        [mLock unlock];
    };

    if ([[NSThread currentThread] isMainThread])
        block();
    else
        dispatch_sync(dispatch_get_main_queue(), ^{ block(); });
    
    return task;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = (int)[httpResponse statusCode];
    
    NSLog(@"Redirect with code %d", code);
    
    if (!request)
    {
        completionHandler(nil);
    }
    else if (rs::Model::instance()->currentOperationMode() == rs::kRSOperationModeInnerOff)
    {
        completionHandler(request);
    }
    else
    {
        request = [RSURLRequestProcessor proccessRequest:request isEdge:YES];
        completionHandler(request);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [mLock lock];
    int connectionId = [dataTask.taskDescription intValue];
    std::unordered_map<int, std::shared_ptr<rs::Connection>>::iterator w = mConnections.find(connectionId);
    assert(w != mConnections.end());
    std::shared_ptr<rs::Connection> connection = w->second;
    [mLock unlock];

    connection->didReceiveData((__bridge void *)data);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [mLock lock];
    int connectionId = [dataTask.taskDescription intValue];
    std::unordered_map<int, std::shared_ptr<rs::Connection>>::iterator w = mConnections.find(connectionId);
    assert(w != mConnections.end());
    std::shared_ptr<rs::Connection> connection = w->second;
    [mLock unlock];
    
    connection->didReceiveResponse((__bridge void*)response);
    
    if (completionHandler)
        completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [mLock lock];
    int connectionId = [task.taskDescription intValue];
    std::unordered_map<int, std::shared_ptr<rs::Connection>>::iterator w = mConnections.find(connectionId);
    assert(w != mConnections.end());
    std::shared_ptr<rs::Connection> connection = w->second;
    [mLock unlock];
    
    connection->didCompleteWithError((__bridge void*)error);

    [mLock lock];
    mConnections.erase(w);
    [mLock unlock];
}

@end
