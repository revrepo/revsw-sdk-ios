//
//  RSTestModel.m
//  RevTest App
//
//  Created by Andrey Chernukha on 12/4/15.
//
//

#import <RevSDK/RevSDK.h>

#import "RTTestModel.h"

@interface RTTestModel ()
{
    NSUInteger mTestsCounter;
    NSUInteger mNumberOfTestsToPerform;
    BOOL mIsLoading;
    NSDate* mStartDate;
    NSUInteger mCurrentDataSize;
}

@property (nonatomic, strong) NSMutableArray* testResults;
@property (nonatomic, strong) NSMutableArray* sdkTestResults;
@property (nonatomic, strong) NSMutableArray* dataLengthArray;
@property (nonatomic, strong) NSMutableArray* sdkDataLengthArray;

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
        
         [RevSDK setWhiteListOption:NO];
        
         [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(didReceiveStopLoadingNotification:)
                                                      name:@"kRSURLProtocolStoppedLoading"
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
}

- (void)start
{
    mCurrentDataSize = 0;
    self.shouldLoad  = YES;
    mTestsCounter    = 0;
    
    [RevSDK setOperationMode:kRSOperationModeOff];
    [RevSDK setTestPassOption:YES];
    [self.testResults removeAllObjects];
    [self.sdkTestResults removeAllObjects];
    [self.dataLengthArray removeAllObjects];
    [self.sdkDataLengthArray removeAllObjects];
}

- (void)setWhiteListOption:(BOOL)aOn
{
    [RevSDK setWhiteListOption:aOn];
}

- (void)setNumberOfTests:(NSUInteger)aNumberOfTests
{
    mNumberOfTestsToPerform = aNumberOfTests;
}

- (void)loadStarted
{
    if (!mIsLoading)
    {
        ++mTestsCounter;
        mIsLoading = YES;
        mStartDate = [NSDate date];
        
        NSString* type = [RevSDK operationMode] == kRSOperationModeOff ? @"Origin" : @"SDK";
        NSString* pass = [NSString stringWithFormat:@"Pass: %ld / %ld", mTestsCounter, mNumberOfTestsToPerform];
        NSString* text = [NSString stringWithFormat:@"%@ %@", type, pass];
        
        NSLog(@"Start %ld", mTestsCounter);
        
        if (self.loadStartedBlock)
        {
            self.loadStartedBlock(text);
        }
    }
}

- (void)loadFinished
{
    NSLog(@"Finish %ld", mTestsCounter);
    
    mIsLoading              = NO;
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:mStartDate];
    mStartDate              = nil;
    NSMutableArray* array   = [RevSDK operationMode] == kRSOperationModeOff ? self.testResults : self.sdkTestResults;
    [array addObject:@(interval)];
    
    array = [RevSDK operationMode] == kRSOperationModeOff ? self.dataLengthArray : self.sdkDataLengthArray;
    [array addObject:@(mCurrentDataSize)];
    mCurrentDataSize = 0;
    
    if (self.loadFinishedBlock)
    {
        self.loadFinishedBlock();
    }
    
    if (mTestsCounter < mNumberOfTestsToPerform)
    {
        if (self.restartBlock)
        {
            self.restartBlock();
        }
    }
    else
    {
        if (self.sdkTestResults.count == 0)
        {
            [RevSDK setOperationMode:kRSOperationModeTransport];
            [RevSDK setTestPassOption:NO];
            
            mTestsCounter = 0;

            if (self.restartBlock)
            {
                self.restartBlock();
            }
        }
        else
        {
            if (self.completionBlock)
            {
                self.completionBlock(self.testResults, self.sdkTestResults, self.dataLengthArray, self.sdkDataLengthArray);
            }
            
            self.shouldLoad = NO;
        }
    }
}

@end
