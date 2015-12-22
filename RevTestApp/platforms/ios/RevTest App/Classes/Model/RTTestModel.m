//
//  RSTestModel.m
//  RevTest App
//
//  Created by Andrey Chernukha on 12/4/15.
//
//

#import "RTTestModel.h"

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
@property (nonatomic, strong) NSMutableArray* sdkTestResults;
@property (nonatomic, strong) NSMutableArray* dataLengthArray;
@property (nonatomic, strong) NSMutableArray* sdkDataLengthArray;

@property (nonatomic, strong) NSMutableArray* resultFlags;

@property (nonatomic, strong) NSTimer* timer;

@end

@implementation RTTestModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
         mTestsCounter           = 0;
         mNumberOfTestsToPerform = 0;
         mCurrentDataSize        = 0;
         mIsLoading              = NO;
         self.shouldLoad         = NO;
         self.testResults        = [NSMutableArray array];
         self.sdkTestResults     = [NSMutableArray array];
         self.dataLengthArray    = [NSMutableArray array];
         self.sdkDataLengthArray = [NSMutableArray array];
         self.resultFlags = [NSMutableArray array];
        
         [RevSDK setWhiteListOption:NO];
        
         [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(didReceiveStopLoadingNotification:)
                                                      name:kRSURLProtocolStoppedLoadingNotification
                                                    object:nil];
    }
    
    return self;
}

- (void)didReceiveStopLoadingNotification:(NSNotification *)aNotification
{
    NSDictionary* userInfo = aNotification.userInfo;
    NSNumber* number       = userInfo[kRSDataKey];
    NSUInteger dataSize    = number.unsignedIntegerValue;
    
    mCurrentDataSize += dataSize;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start
{
    [RevSDK debug_stopConfigurationUpdate];
    mCurrentDataSize = 0;
    self.shouldLoad  = YES;
    mTestsCounter    = 0;
    
    [self.testResults removeAllObjects];
    [self.sdkTestResults removeAllObjects];
    [self.dataLengthArray removeAllObjects];
    [self.sdkDataLengthArray removeAllObjects];
    [self.resultFlags removeAllObjects];
    
    mMode = kRSOperationModeOff;
    
    [RevSDK debug_setOperationMode:mMode];
    [self stepStarted];
}

- (void)setWhiteListOption:(BOOL)aOn
{
    [RevSDK setWhiteListOption:aOn];
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
        mIsLoading = YES;
        mStartDate = [NSDate date];
        
        NSString* type = [RevSDK operationMode] == kRSOperationModeOff ? @"Origin" : @"SDK";
        
        NSLog(@"-test: %ld mode: %@", (unsigned long)mTestsCounter, type);
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:45.0
                                                      target:self
                                                    selector:@selector(timerFired)
                                                    userInfo:nil
                                                     repeats:NO];
    }
}

- (void)didFinishedTests
{
    [RevSDK debug_resumeConfigurationUpdate];
}

- (void)stepStarted
{
    ++mTestsCounter;
    if (mTestsCounter <= mNumberOfTestsToPerform)
    {
        NSLog(@"Start %ld", (unsigned long)mTestsCounter);
        
        mMode = kRSOperationModeOff;
        
        NSString* type = @" ";//[RevSDK operationMode] == kRSOperationModeOff ? @"Origin" : @"SDK";
        NSString* pass = [NSString stringWithFormat:@"Pass: %ld / %ld", (unsigned long)mTestsCounter, (unsigned long)mNumberOfTestsToPerform];
        NSString* text = [NSString stringWithFormat:@"%@ %@", type, pass];
        
        if (self.loadStartedBlock)
        {
            self.loadStartedBlock(text);
        }
    }
}

- (void)loadFinished
{
    if (self.timer)
    {
        [self.timer invalidate];
         self.timer = nil;
    }
    
    mIsLoading              = NO;
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:mStartDate];
    mStartDate              = nil;
    NSMutableArray* array   = [RevSDK operationMode] == kRSOperationModeOff ? self.testResults : self.sdkTestResults;
    [array addObject:@(interval)];
    
    array = [RevSDK operationMode] == kRSOperationModeOff ? self.dataLengthArray : self.sdkDataLengthArray;
    [array addObject:@(mCurrentDataSize / 1024.0)];
    mCurrentDataSize = 0;
    
    
    if (kRSOperationModeOff == mMode)
    {
        mMode = kRSOperationModeTransport; 
    }
    else
    {
        mMode = kRSOperationModeOff;
    } 
    
    if (self.loadFinishedBlock)
    {
        self.loadFinishedBlock();
    }
    
    [RevSDK debug_setOperationMode:mMode];
    
    bool isLastTest = (kRSOperationModeOff == mMode) && (mTestsCounter == mNumberOfTestsToPerform);
    if (mTestsCounter <= mNumberOfTestsToPerform && !isLastTest)
    {
        if (self.restartBlock)
        {
            self.restartBlock(); 
        }
    }
}

- (void)stepFinished:(bool)withSuccess
{
    [self.resultFlags addObject:[NSNumber numberWithBool:withSuccess]];
    
    if (mTestsCounter >= mNumberOfTestsToPerform)
    {
        self.shouldLoad = NO;
        if (self.completionBlock)
        {
            self.completionBlock(self.testResults, self.sdkTestResults, self.dataLengthArray, self.sdkDataLengthArray, self.resultFlags);
        }
        [self didFinishedTests];
    }
    NSLog(@"Finish %ld", (unsigned long)mTestsCounter);
}

@end
