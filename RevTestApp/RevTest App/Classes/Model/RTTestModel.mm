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

#import "RTTestModel.h"
#import "RTIterationResult.h"

#import <RevSDK/RevSDK.h>
#import "RTUtils.h"

typedef enum
{
    kRSOperationModeOff,
    kRSOperationModeTransport,
    kRSOperationModeReport,
    kRSOperationModeTransportAndReport
}RSOperationMode;


@interface RTTestModel ()
{
    NSUInteger mTestsCounter;
    NSUInteger mNumberOfTestsToPerform;
    BOOL mIsLoading;
    NSDate* mStartDate;
    NSUInteger mCurrentDataSize;
    
    RSOperationMode mMode;
}

@property (nonatomic, strong) NSMutableArray* testResults;
@property (nonatomic, strong) NSMutableArray* testCases;
@property (nonatomic, strong) NSString* urlString;
@property (nonatomic, strong) RTIterationResult* currentResult;

@property (nonatomic, strong) NSTimer* timer;

@end

@implementation RTTestModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
         [RTTestResult setShouldReportDataInMB:NO];
        
         mTestsCounter           = 0;
         mNumberOfTestsToPerform = 0;
         mCurrentDataSize        = 0;
         mIsLoading              = NO;
         self.shouldLoad         = NO;
         self.testResults        = [NSMutableArray array];
        
         [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(didReceiveStopLoadingNotification:)
                                                      name:@"kRSURLProtocolStoppedLoadingNotification"
                                                    object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetTimer)
                                                     name:@"kRSURLProtocolDidReceiveResponseNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetTimer)
                                                     name:@"kRSURLProtocolDidReceiveDataNotification"
                                                   object:nil];
    }
    
    return self;
}

- (void)didReceiveStopLoadingNotification:(NSNotification *)aNotification
{
    NSDictionary* userInfo = aNotification.userInfo;
    NSNumber* number       = userInfo[@"kRSDataKey"];
    NSUInteger dataSize    = number.unsignedIntegerValue;
    NSString* host         = userInfo[@"kRSHostKey"];
    
    if (![host isEqualToString:@"mobile-collector.newrelic.com"])
    {
        mCurrentDataSize += dataSize;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    SEL selector = @selector(debug_disableTestMode);
    
    if ([RevSDK respondsToSelector:selector])
    {
        [RevSDK performSelector:selector];
    }
}

- (void)start
{
    [RTTestResult setShouldReportDataInMB:NO];
    
    mCurrentDataSize   = 0;
    self.shouldLoad    = YES;
    mTestsCounter      = 0;
    
    self.currentResult = [[RTIterationResult alloc ]init];
    
    [self.testResults removeAllObjects];
    
    SEL selector = @selector(debug_enableTestMode);
    
    if ([RevSDK respondsToSelector:selector])
    {
        [RevSDK performSelector:selector];
    }
    
    [self stepStarted];
}

- (void)createCases
{
    self.testCases = [NSMutableArray array];
    
    RTTestCase* tcase = [[RTTestCase alloc] init];
    // 1st case
    tcase.testName = @"Current";
    tcase.protocolID = @"none";
    tcase.operationMode = RSOperationMode::kRSOperationModeReport;
    
    [self.testCases addObject:tcase];
    ////////////////////////////////
    
    tcase = [[RTTestCase alloc] init];
    tcase.testName = @"DOTS";
    tcase.protocolID = @"standard";
    tcase.operationMode = RSOperationMode::kRSOperationModeTransportAndReport;
    
    [self.testCases addObject:tcase];
    ////////////////////////////////
    
    tcase = [[RTTestCase alloc] init];
    tcase.testName = @"RevSDK";
    tcase.protocolID = @"quic";
    tcase.operationMode = RSOperationMode::kRSOperationModeTransportAndReport;
    
    [self.testCases addObject:tcase];
    ////////////////////////////////
}

- (void)toNextCase
{
    [self.testCases removeObjectAtIndex:0];
    if ([self.testCases count])
    {
        RTTestCase* tcase = [self.testCases objectAtIndex:0];
        
        RSOperationMode mode = (RSOperationMode) tcase.operationMode;
        
        [self pushTestConfiguration:tcase.protocolID mode:mode];
        NSString* type = tcase.testName;
        
        NSLog(@"-test: %ld mode: %@", (unsigned long)mTestsCounter, type);
    }
}

- (void)setWhiteListOption:(BOOL)aOn
{
    //[RevSDK setWhiteListOption:aOn];
}

- (void)setNumberOfTests:(NSUInteger)aNumberOfTests
{
    mNumberOfTestsToPerform = aNumberOfTests;
}

- (void)invalidateTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerFired
{
    [self.timer invalidate];
    self.timer = nil;
    
    RTPerformBlockOnMainQueue(self.cancelBlock);
}

- (void)loadStarted
{
    if (!mIsLoading)
    {
        if ([self.testCases count] == 0)
        {
            [self stepFinished];
            [self stepStarted];
        }
        
        mIsLoading = YES;
        
        mStartDate = [NSDate date];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:45.0
                                                      target:self
                                                    selector:@selector(timerFired)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)didFinishedTests
{
    SEL selector = @selector(debug_disableTestMode);
    
    if ([RevSDK respondsToSelector:selector])
    {
        [RevSDK performSelector:selector];
    }
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

- (void)stepStarted
{
    ++mTestsCounter;
    if (mTestsCounter <= mNumberOfTestsToPerform)
    {
        NSLog(@"Start %ld", (unsigned long)mTestsCounter);
        
        [self createCases];
        RTTestCase* tcase = [self.testCases objectAtIndex:0];
        RSOperationMode mode = (RSOperationMode) tcase.operationMode;
        
        [self pushTestConfiguration:tcase.protocolID mode:mode];
        
        NSString* proto = tcase.testName;
        
        NSLog(@"-test: %ld mode: %@", (unsigned long)mTestsCounter, proto);
        
        NSString* type = @" ";//[RevSDK operationMode] == kRSOperationModeOff ? @"Origin" : @"SDK";
        NSString* pass = [NSString stringWithFormat:@"Pass: %ld / %ld", (unsigned long)mTestsCounter, (unsigned long)mNumberOfTestsToPerform];
        NSString* text = [NSString stringWithFormat:@"%@ %@", type, pass];
        
        if (self.loadStartedBlock)
        {
            self.loadStartedBlock(text);
        }
    }
}

- (void)resetTimer
{
    if (mIsLoading)
    {
        [self.timer invalidate];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:45.0
                                                      target:self
                                                    selector:@selector(timerFired)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)loadFinished:(NSInteger) aResult
{
    if ([self.testCases count] == 0)
    {
        return;
    }
    
    if (self.timer)
    {
        [self.timer invalidate];
         self.timer = nil;
    }
    RTTestResult* tres = [[RTTestResult alloc] init];
    
    mIsLoading              = NO;
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:mStartDate];
    mStartDate              = nil;
    
    const CGFloat kCylobyte          = 1024.0;
    const NSUInteger kCylobytesLimit = 300;
    const NSUInteger kDataSizeLimit  = kCylobytesLimit * kCylobyte;
    
    if (mCurrentDataSize > kDataSizeLimit)
    {
        [RTTestResult setShouldReportDataInMB:YES];
    }
    
    tres.dataLength  = mCurrentDataSize;
    
    tres.errorCode   = aResult;
    
    tres.duration    = interval;
    mCurrentDataSize = 0;
    
    RTTestCase* tcase = [self.testCases objectAtIndex:0];
    tres.testName     = tcase.testName;
    
    [self.currentResult pushResult:tres];
    
    [self toNextCase];
    
    if (self.loadFinishedBlock)
    {
        self.loadFinishedBlock();
    }
    
    if (mTestsCounter < mNumberOfTestsToPerform ||
        ([self.testCases count] > 0))
    {
        if (self.restartBlock)
        {
            self.restartBlock(); 
        }
    }
    else
    {
        [self stepFinished];
    }
    
}

- (void)stepFinished
{
    [self.testResults addObject:self.currentResult];
    
    self.currentResult = [[RTIterationResult alloc ]init];
    
    if (mTestsCounter >= mNumberOfTestsToPerform)
    {
        self.shouldLoad = NO;
        if (self.completionBlock)
        {
            self.completionBlock(self.testResults);
        }
        
        [self didFinishedTests];
    }
    NSLog(@"Finish %ld", (unsigned long)mTestsCounter);
}

@end
