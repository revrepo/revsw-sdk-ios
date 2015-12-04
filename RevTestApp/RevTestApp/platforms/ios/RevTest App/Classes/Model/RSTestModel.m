//
//  RSTestModel.m
//  RevTest App
//
//  Created by Andrey Chernukha on 12/4/15.
//
//

#import <RevSDK/RevSDK.h>

#import "RSTestModel.h"

@interface RSTestModel ()
{
    NSUInteger mTestsCounter;
    NSUInteger mNumberOfTestsToPerform;
    BOOL mIsLoading;
    NSDate* mStartDate;    
}

@property (nonatomic, strong) NSMutableArray* testResults;
@property (nonatomic, strong) NSMutableArray* sdkTestResults;

@end

@implementation RSTestModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
         mIsLoading = NO;
        
         self.testResults    = [NSMutableArray array];
         self.sdkTestResults = [NSMutableArray array];
         
         mTestsCounter           = 0;
         mNumberOfTestsToPerform = 0;
        
         [RevSDK setWhiteListOption:NO];
    }
    
    return self;
}

- (void)start
{
    mTestsCounter = 0;
    [RevSDK setOperationMode:kRSOperationModeOff];
    [self.testResults removeAllObjects];
    [self.sdkTestResults removeAllObjects];
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
        mIsLoading                        = YES;
        mStartDate                        = [NSDate date];
        
        if (self.loadStartedBlock)
        {
            self.loadStartedBlock();
        }
    }
}

- (void)loadFinished
{
    mIsLoading              = NO;
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:mStartDate];
    mStartDate              = nil;
    NSMutableArray* array   = [RevSDK operationMode] == kRSOperationModeOff ? self.testResults : self.sdkTestResults;
    [array addObject:@(interval)];
    
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
                self.completionBlock(self.testResults, self.sdkTestResults);
            }
        }
    }
}

@end
