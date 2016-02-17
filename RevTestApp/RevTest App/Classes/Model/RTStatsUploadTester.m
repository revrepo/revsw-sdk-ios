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

#import "RTStatsUploadTester.h"
#import "RTUtils.h"

@interface RTStatsUploadTester ()

@property (nonatomic, assign) NSUInteger requestCounter;
@property (nonatomic, assign) NSUInteger numberOfRequests;
@property (nonatomic, assign) NSUInteger numberOfPasses;
@property (nonatomic, copy)   NSString*  URLString;

@end

@implementation RTStatsUploadTester

+ (instancetype)defaultTester
{
    return [[RTStatsUploadTester alloc] initWithNumberOfRequests:30
                                                  numberOfPasses:10
                                                       URLString:@"http://httpbin.org"];
}

- (instancetype)initWithNumberOfRequests:(NSUInteger)aRequests numberOfPasses:(NSUInteger)aPasses URLString:(NSString *)aURLString
{
    self = [super init];
    
    if (self)
    {
        _requestCounter   = 0;
        _numberOfRequests = aRequests;
        _numberOfPasses   = aPasses;
        _URLString        = [aURLString copy];
    }
    
    return self;
}

- (void)start
{
    SEL selector = @selector(debug_enableStatsUploadTestMode);
    [RevSDK performSelector:selector];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRequestsCount:)
                                                 name:@"kRequestsCountNotification"
                                               object:nil];
    
    [self startIteration];
}

- (void)startIteration
{
    NSURL* URL = [NSURL URLWithString:self.URLString];
    NSURLRequest* URLRequest = [NSURLRequest requestWithURL:URL];
    
    for (int i = 0; i < self.numberOfRequests; i++)
    {
        [NSURLConnection connectionWithRequest:URLRequest delegate:nil];
    }
}

- (void)didReceiveRequestsCount:(NSNotification *)aNotification
{
    self.requestCounter++;
    
    NSDictionary* userInfo   = aNotification.userInfo;
    NSString* countString    = userInfo[@"info_key"];
    NSUInteger requestsCount = [countString integerValue];
    
    if (requestsCount != self.numberOfRequests)
    {
        NSString* errorMessage = [NSString stringWithFormat:@"Stats uploading test failed with requests count %ld expected requests count %ld", requestsCount, self.numberOfRequests];
        
        [self finishWithMessage:errorMessage
                         result:@NO];
    }
    else
    {
        if (self.requestCounter >= self.numberOfPasses)
        {
            [self finishWithMessage:@"Success"
                             result:@YES];
        }
        else
        {
            [self startIteration];
        }
    }
}

- (void)finishWithMessage:(NSString *)aMessage result:(NSNumber *)aResult
{
    SEL selector = @selector(debug_disableTestMode);
    [RevSDK performSelector:selector];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSDictionary* userInfo = @{
                               kRTErrorKey : aMessage,
                               kRTResultKey : aResult
                               };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRTStatsTesterDidFinishNotification
                                                        object:nil
                                                      userInfo:userInfo];
    

}

@end
