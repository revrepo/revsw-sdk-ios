//
//  RSTestModel.m
//  RevTest App
//
//  Created by Andrey Chernukha on 12/4/15.
//
//

#import "RTTestModel.h"
#import "RTIterationResult.h"

#import <RevSDK/RevSDK.h>
#import "RTUtils.h"


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
    }
    
    return self;
}

- (void)didReceiveStopLoadingNotification:(NSNotification *)aNotification
{
    NSDictionary* userInfo = aNotification.userInfo;
    NSNumber* number       = userInfo[@"kRSDataKey"];
    NSUInteger dataSize    = number.unsignedIntegerValue;
    
    mCurrentDataSize += dataSize;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [RevSDK debug_disableTestMode];
}

- (void)start
{
    [RTTestResult setShouldReportDataInMB:NO];
    
    mCurrentDataSize   = 0;
    self.shouldLoad    = YES;
    mTestsCounter      = 0;
    
    self.currentResult = [[RTIterationResult alloc ]init];
    
    [self.testResults removeAllObjects];
    
    [RevSDK debug_enableTestMode];
    [self stepStarted];
}

- (void)createCases
{
    self.testCases = [NSMutableArray array];
    
    RTTestCase* tcase = [[RTTestCase alloc] init];
    // 1st case
    tcase.testName = @"Origin";
    tcase.protocolID = @"none";
    tcase.operationMode = RSOperationMode::kRSOperationModeReport;
    
    [self.testCases addObject:tcase];
    ////////////////////////////////
    
    tcase = [[RTTestCase alloc] init];
    tcase.testName = @"Standard";
    tcase.protocolID = @"standard";
    tcase.operationMode = RSOperationMode::kRSOperationModeTransportAndReport;
    
    [self.testCases addObject:tcase];
    ////////////////////////////////
    
    tcase = [[RTTestCase alloc] init];
    tcase.testName = @"QUIC";
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
        
        [RevSDK debug_pushTestConifguration:tcase.protocolID mode:mode];
        
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
    [RevSDK debug_disableTestMode];
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
        [RevSDK debug_pushTestConifguration:tcase.protocolID mode:mode];
        
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

- (void)loadFinished:(NSInteger) aResult
{
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
    
    assert([self.testCases count]);
    
    RTTestCase* tcase = [self.testCases objectAtIndex:0];
    tres.testName = tcase.testName;
    
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
