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

#import <RevSDK/RevSDK.h>

#import "RTProtocolSwitchTester.h"
#import "RTUtils.h"

@interface RTProtocolSwitchTester ()
{
    BOOL mWaitingForBestProtocol;
    int mSuccessCounter;
    int mNumberOfPasses;
    int mPassesCounter;
}

@property (nonatomic, copy) NSString* URLAddress;

@end

@implementation RTProtocolSwitchTester

+ (instancetype)defaultTester
{
    return [[RTProtocolSwitchTester alloc] initWithURLAddress:@"http://httpbin.org" passes:5];
}

- (instancetype)initWithURLAddress:(NSString *)aURLAddress passes:(int)aPasses
{
    self = [super init];
    
    if (self)
    {
        mNumberOfPasses         = aPasses;
        mPassesCounter          = 0;
        mWaitingForBestProtocol = NO;
        mSuccessCounter         = 0;
        _URLAddress             = [aURLAddress copy];
    }
    
    return self;
}

- (void)start
{
    mWaitingForBestProtocol = NO;
    
    [self makeRequestToURL:self.URLAddress completionBlock:^(BOOL aSuccess){
    
        if (aSuccess)
        {
            [self startIteration];
        }
        else
        {
            NSString* errorMessage = [NSString stringWithFormat:@"Unable to continue. Initial request failed %@", self.URLAddress];
            
            [self finishWithMessage:errorMessage
                             result:@NO];
        }
    }];
    
    static const int kFailDelay = 300;
    
    [self performSelector:@selector(didFail)
               withObject:nil
               afterDelay:kFailDelay];
}

- (void)startIteration
{
    SEL selector = @selector(debug_enableErrorMode);
    [RevSDK performSelector:selector];
    
    mWaitingForBestProtocol = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(protocolSelected)
                                                 name:@"kBestProtocolSelected"
                                               object:nil];
    
    [self recursiveCall];
}

- (void)protocolSelected
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"kBestProtocolSelected"
                                                  object:nil];
    mWaitingForBestProtocol = NO;
}

- (void)recursiveCall
{
    NSLog(@".");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(mWaitingForBestProtocol)
        {
            [self makeRequestToURL:@"http://httpbin.org"
                   completionBlock:^(BOOL aSuccess){
                       
                       [self recursiveCall]; }];
        }
        else
        {
            SEL selector = @selector(debug_disableTestMode);
            [RevSDK performSelector:selector];
        
            [self makeRequestToURL:@"http://httpbin.org"
                   completionBlock:^(BOOL aSuccess){
                       
                       if (aSuccess)
                       {
                           mSuccessCounter++;
                           
                           if (mSuccessCounter < 2)
                           {
                               [self startIteration];
                           }
                           else
                           {
                               mSuccessCounter = 0;
                               mPassesCounter++;
                               
                               if (mPassesCounter < mNumberOfPasses)
                               {
                                   [self startIteration];
                               }
                               else
                               {
                                   [self finishWithMessage:@"Success"
                                                    result:@YES];
                               }
                           }
                       }
                       else
                       {
                           NSString* errorMessage = [NSString stringWithFormat:@"Unable to continue. Second attempt failed %@", self.URLAddress];
                           
                           [self finishWithMessage:errorMessage
                                            result:@NO];
                       }
                   }];
        }
        
    });
}

- (void)makeRequestToURL:(NSString *)URLAddress completionBlock:(void(^)(BOOL))aCompletionBlock
{
    NSURL* URL = [NSURL URLWithString:URLAddress];
    NSURLRequest* request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                             completionHandler:^(NSData* data, NSURLResponse* response, NSError* error){
                                                                 
                                                                 if (aCompletionBlock)
                                                                 {
                                                                     aCompletionBlock(error == nil);
                                                                 }
                                                             }];
    
    [task resume];

}

- (void)finishWithMessage:(NSString *)aMessage result:(NSNumber *)aResult
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSDictionary* userInfo = @{
                               kRTErrorKey : aMessage,
                               kRTResultKey : aResult
                               };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRTProtocolSwitchTesterDidFinish
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)didFail
{
    NSString* errorMessage = [NSString stringWithFormat:@"Time is up %@", self.URLAddress];
    
    [self finishWithMessage:errorMessage
                     result:@NO];

}

@end
