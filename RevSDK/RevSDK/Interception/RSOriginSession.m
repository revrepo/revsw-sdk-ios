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

#import <UIKit/UIKit.h>

#import "RSOriginSession.h"

@interface RSLockedMap : NSObject
{
    NSMutableDictionary* mMap;
    NSLock* mLock;
}

- (void)setDelegate:(id)aDelegate forConnectionId:(NSString*)aConnectionId;
- (void)removeConnectionId:(NSString*)aConnectionId;
- (id)delegateForConnectionId:(NSString*)aConnectionId;

@end

@implementation RSLockedMap

- (id)init
{
    if (self = [super init])
    {
        mMap = [[NSMutableDictionary alloc] init];
        mLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)setDelegate:(id)aDelegate forConnectionId:(NSString*)aConnectionId
{
    if (aDelegate == nil || aConnectionId == nil)
        return;
    
    [mLock lock];
    [mMap setObject:aDelegate forKey:aConnectionId];
    [mLock unlock];
}

- (void)removeConnectionId:(NSString*)aConnectionId
{
    if (aConnectionId == nil)
        return;
    
    [mLock lock];
    [mMap removeObjectForKey:aConnectionId];
    [mLock unlock];
}

- (id)delegateForConnectionId:(NSString*)aConnectionId
{
    if (aConnectionId == nil)
        return nil;
    
    id result = nil;
    [mLock lock];
    result = [mMap objectForKey:aConnectionId];
    [mLock unlock];
    return result;
}

@end

static void displayStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        [[RSOriginSession instance] createSession];
    }
}

@interface RSOriginSession()<NSURLSessionDataDelegate>
{
    NSLock* mLock;
    BOOL mInitialized;
}

@property (nonatomic, readwrite, strong) NSURLSessionConfiguration* configuration;
@property (nonatomic, readwrite, strong) NSThread* thread;
@property (nonatomic, readwrite, strong) NSTimer* timer;
@property (nonatomic, readwrite, strong) NSURLSession* session;
@property (nonatomic, readwrite, strong) RSLockedMap* map;

- (void)p_createTaskWithParams:(NSDictionary*)aParams;

@end

@implementation RSOriginSession

+ (NSString*)uniqueConnectionIdentifier
{
    static NSLock* lock = nil;
    static int cnt = 0;
    
    if (lock == nil)
        lock = [[NSLock alloc] init];
    
    [lock lock];
    int value = cnt++;
    [lock unlock];
    
    return [NSString stringWithFormat:@"%d", value];
}

+ (RSOriginSession*)instance
{
    static dispatch_once_t pred = 0;
    __strong static RSOriginSession* mInstance = nil;
    
    dispatch_once(&pred, ^
    {
        if ([[NSThread currentThread] isMainThread])
        {
            mInstance = [[RSOriginSession alloc] init];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                mInstance = [[RSOriginSession alloc] init];
            });
        }
    });
    
    return mInstance;
}

- (id)init
{
    if (self = [super init])
    {
        mInitialized = NO;
        self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadRun:) object:nil];
        [self.thread start];
        
        mLock = [[NSLock alloc] init];
        
        self.map = [[RSLockedMap alloc] init];
    }
    return self;
}

- (void)onTimerFired:(NSTimer*)aTimer {}

- (void)threadRun:(id)ctx
{
    @autoreleasepool {
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        displayStatusChanged,
                                        CFSTR("com.apple.springboard.lockstate"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
        
        [self createSession];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                    target:self
                                                    selector:@selector(onTimerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
        mInitialized = YES;
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)createSession
{
    self.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.session = [NSURLSession sessionWithConfiguration:self.configuration
                                                 delegate:self
                                            delegateQueue:nil];
}

- (void)createTaskWithRequest:(NSURLRequest*)aRequest
                     delegate:(id<NSURLSessionDataDelegate>)aDelegate
{
    if (aRequest == nil || aDelegate == nil)
        return;
    
    NSString* connectionIdStr = [RSOriginSession uniqueConnectionIdentifier];
    NSDictionary* params = @{@"r":aRequest, @"id":connectionIdStr, @"d":aDelegate};
    
    if ([NSThread currentThread] == self.thread)
    {
        [self p_createTaskWithParams:params];
    }
    else
    {
        [self performSelector:@selector(p_createTaskWithParams:)
                     onThread:self.thread
                   withObject:params
                waitUntilDone:NO];
    }
}

- (void)p_createTaskWithParams:(NSDictionary *)aParams
{
    NSAssert([NSThread currentThread] == self.thread, @"Wrong thread!");
    NSURLRequest* request = aParams[@"r"];
    NSString* connectionId = aParams[@"id"];
    id delegate = aParams[@"d"];
    NSAssert(request != nil && connectionId != nil && delegate != nil, @"Bad parameters!");
    
    [self.map setDelegate:delegate forConnectionId:connectionId];
    
    NSURLSessionTask* task = [self.session dataTaskWithRequest:request];
    task.taskDescription = connectionId;
    [task resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    id<NSURLSessionDataDelegate> delegate = [self.map delegateForConnectionId:task.taskDescription];
    [delegate URLSession:session
                    task:task
    didCompleteWithError:error];
    if (task.state == NSURLSessionTaskStateCompleted)
        [self.map removeConnectionId:task.taskDescription];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    id<NSURLSessionDataDelegate> delegate = [self.map delegateForConnectionId:dataTask.taskDescription];
    [delegate URLSession:session
                dataTask:dataTask
          didReceiveData:data];
    if (dataTask.state == NSURLSessionTaskStateCompleted)
        [self.map removeConnectionId:dataTask.taskDescription];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    id<NSURLSessionDataDelegate> delegate = [self.map delegateForConnectionId:dataTask.taskDescription];
    [delegate URLSession:session
                dataTask:dataTask
      didReceiveResponse:response
       completionHandler:completionHandler];
    
    if (dataTask.state == NSURLSessionTaskStateCompleted)
        [self.map removeConnectionId:dataTask.taskDescription];
}

@end
