/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
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

#import "RTRequestTestLoop.h"
#import "RTHTMLGrabber.h"
#import "RTTestModel.h"
#import "RTUtils.h"

@interface NSString (URLString)

- (instancetype)stringByAddingScheme;

@end

@implementation NSString (URLString)

- (instancetype)stringByAddingScheme
{
    if (![self hasPrefix:@"http://"] && ! [self hasPrefix:@"https://"])
    {
        return [@"http://" stringByAppendingString:self];
    }
    
    return self;
}

@end

typedef enum
{
    kRSOperationModeOff = 0,
    kRSOperationModeTransport = 1,
    kRSOperationModeReport = 2,
    kRSOperationModeTransportAndReport = 3
}RSOperationMode;

@interface RTRequestTestLoop ()<RTHTMLGrabberDelegate>

@property (nonatomic, strong) RTHTMLGrabber* htmlGrabber;
@property (nonatomic, strong) NSArray* domains;
@property (nonatomic, strong) NSMutableArray* testCases;
@property (nonatomic, assign) NSUInteger currentDomainIndex;
@property (nonatomic, assign) NSUInteger iterationIndex;
@property (nonatomic, assign) NSUInteger numberOfTests;
@property (nonatomic, assign) NSUInteger numberOfFullPasses;
@property (nonatomic, assign) NSUInteger currentPass;
@property (nonatomic, assign) BOOL isIterating;
@property (nonatomic, strong) RTTestCase* currentTestCase;
@property (nonatomic, strong) NSMutableArray* statusCodes;

@end

@implementation RTRequestTestLoop

+ (NSArray *)defaultDomains
{
//    return @[@"mgemi.com",
//             @"httpbin.org",
//             @"google.com",
//             @"mbeans.com",
//             @"cnn.com",
//             @"stackoverflow.com",
//             @"bmwusa.com",
//             @"ebay.com",
//             @"m.vk.com",
//             @"yandex.ru",
//             @"amazon.com",
//             @"youtube.com",
//             @"linkedin.com",
//             @"echo.msk.ru",
//             @"ibm.com",
//             @"revapm.net",
//             @"bing.com",
//             @"akamai.com",
//             @"skrill.com",
//             @"raywenderlich.com",
//             @"facebook.com",
//             @"twitter.com"];
    return @[@"monitor.revsw.net/100KB.jpg",
             @"monitor.revsw.net/1M.jpg",
             @"monitor.revsw.net/test-cache.js",
             @"google.com"];
}

+ (instancetype)defaultTestLoop
{
    NSArray* domains = [self defaultDomains];
    
    RTRequestTestLoop* testLoop = [[self alloc] initWithDomains:domains
                                                  numberOfTests:3
                                             numberOfFullPasses:1];
    return testLoop;
}

- (instancetype)initWithDomains:(NSArray *)aDomains numberOfTests:(NSUInteger)aNumberOfTests numberOfFullPasses:(NSUInteger)aNumberOfFullPasses
{
    self = [super init];
    
    if (self)
    {
        _statusCodes          = [NSMutableArray array];
        _numberOfTests        = aNumberOfTests;
        _domains              = [aDomains copy];
        _htmlGrabber          = [RTHTMLGrabber new];
        _htmlGrabber.delegate = self;
        _numberOfFullPasses   = aNumberOfFullPasses;
        _testCases            = [NSMutableArray array];
        
        RTTestCase* tcase = [[RTTestCase alloc] init];
        // 1st case
        tcase.testName = @"Current";
        tcase.protocolID = @"none";
        tcase.operationMode = kRSOperationModeReport;
        
        [_testCases addObject:tcase];
        ////////////////////////////////
        
        tcase = [[RTTestCase alloc] init];
        tcase.testName = @"RevAPM";
        tcase.protocolID = @"standard";
        tcase.operationMode = kRSOperationModeTransportAndReport;
        
        [_testCases addObject:tcase];
        ////////////////////////////////
    }
    
    return self;
}

- (void)pushTestConfiguration:(NSString *)aProtocolId mode:(RSOperationMode)mode
{
    SEL selector = @selector(debug_pushTestConifguration: mode:);
    
    if ([RevSDK respondsToSelector:selector])
    {
        NSMethodSignature* methodSignature = [RevSDK methodSignatureForSelector:selector];
        NSInvocation* invocation           = [NSInvocation invocationWithMethodSignature:methodSignature];
        
        [invocation setSelector:selector];
        [invocation setTarget:[RevSDK class]];
        
        [invocation setArgument:&(aProtocolId) atIndex:2];
        [invocation setArgument:&mode atIndex:3];
        
        [invocation invoke];
    }
}

- (void)start
{
    if (self.numberOfFullPasses == 0 || self.numberOfTests == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRTRequestLoopDidFinishNotification
                                                            object:nil
                                                          userInfo:@{
                                                                     kRTResultKey : @NO,
                                                                     kRTErrorKey : [NSString stringWithFormat:@"Incorrect parameters full passes %ld tests %ld", self.numberOfFullPasses, self.numberOfTests ]
                                                                     }];

        return;
    }
    
    if (!self.isIterating)
    {
        self.isIterating = YES;
       [self startIterating];
    }
}

- (SEL)startSelector
{
    return @selector(debug_enableTestMode);
}

- (void)startIterating
{
    SEL selector = [self startSelector];
    [RevSDK performSelector:selector];
    
    RTTestCase* tcase    = [self.testCases objectAtIndex:_iterationIndex % self.testCases.count];
    RSOperationMode mode = (RSOperationMode) tcase.operationMode;
    self.currentTestCase = tcase;
    [self pushTestConfiguration:tcase.protocolID mode:mode];
    
    self.iterationIndex     = 0;
    self.currentDomainIndex = 0;
    
    [self next];
}

- (void)restart
{
    self.iterationIndex++;
    
    if (self.iterationIndex == self.numberOfTests * self.testCases.count)
    {
        self.currentDomainIndex++;
        self.iterationIndex = 0;
    }
    
    if (self.currentDomainIndex < self.domains.count && self.iterationIndex < self.numberOfTests * self.testCases.count)
    {
        RTTestCase* tcase    = [self.testCases objectAtIndex:self.iterationIndex % self.testCases.count];
        RSOperationMode mode = (RSOperationMode) tcase.operationMode;
        [self pushTestConfiguration:tcase.protocolID mode:mode];
        self.currentTestCase = tcase;
        
        [self next];
    }
    else
    if (self.currentDomainIndex == self.domains.count && self.currentPass < self.numberOfFullPasses - 1)
    {
        self.currentPass++;
        [self startIterating];
    }
    else
    {
        [self finish];
    }
}

- (void)finish
{
    self.isIterating = NO;
    
    SEL selector = @selector(debug_disableTestMode);
    [RevSDK performSelector:selector];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRTRequestLoopDidFinishNotification
                                                        object:nil
                                                      userInfo:@{
                                                                 kRTResultKey : @YES,
                                                                 kRTErrorKey : @"Success"
                                                                 }];
}

- (void)next
{
    NSString* URLString   = [self.domains[self.currentDomainIndex] stringByAddingScheme];
    NSURL* URL            = [NSURL URLWithString:URLString];
    NSURLRequest* request = [NSURLRequest requestWithURL:URL];
    [self.htmlGrabber loadRequest:request];
}

#pragma mark - RTHTMLGrabberDelegate

- (void)grabberDidStartLoad:(RTHTMLGrabber *)grabber
{
   
}

- (void)grabberDidFinishLoad:(RTHTMLGrabber *)grabber withStatusCode:(NSInteger)statusCode dataSize:(NSUInteger)aDataSize
{
    [self.statusCodes addObject:@(statusCode)];
    
    if (self.statusCodes.count == self.testCases.count)
    {
        NSInteger firstCode = 0;
        
        for (NSNumber * number in self.statusCodes)
        {
            NSInteger statusCode = number.integerValue;
            
            if (firstCode == 0)
            {
                firstCode = statusCode;
            }
            else
            {
                if (statusCode != firstCode)
                {
                     NSMutableString* errorMessage = [NSMutableString stringWithFormat:@"%@ failed with codes ", self.domains[self.currentDomainIndex]];
                    
                    for (NSNumber * number in self.statusCodes)
                    {
                        [errorMessage appendFormat:@"%ld", number.integerValue];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRTRequestLoopDidFinishNotification
                                                                        object:nil
                                                                      userInfo:@{
                                                                                 kRTResultKey : @NO,
                                                                                 kRTErrorKey : errorMessage
                                                                                 }];
                    break;
                }
            }
        }
        
        [self.statusCodes removeAllObjects];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@".");
        
        [self restart];
    });
}

- (void)grabber:(RTHTMLGrabber *)grabber didFailLoadWithError:(nullable NSError *)error
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self restart];
    });
}

@end

@implementation RTRequestTestLoopOffMode

- (SEL)startSelector
{
    return @selector(debug_setOffMode);
}

- (void)finish
{
    [super finish];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRTOperationModeOffTestDidFinish
                                                        object:nil
                                                      userInfo:@{
                                                                 kRTResultKey : @YES,
                                                                 kRTErrorKey : @"Success"
                                                                 }];
}

@end
