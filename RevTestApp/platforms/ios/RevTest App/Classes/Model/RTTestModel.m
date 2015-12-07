//
//  RSTestModel.m
//  RevTest App
//
//  Created by Andrey Chernukha on 12/4/15.
//
//

#import "MBProgressHUD.h"
#import <RevSDK/RevSDK.h>

#import "RTTestModel.h"

@interface RTTestModel ()
{
    NSUInteger mTestsCounter;
    NSUInteger mNumberOfTestsToPerform;
    BOOL mIsLoading;
    NSDate* mStartDate;    
}

@property (nonatomic, strong) MBProgressHUD* progressHUD;
@property (nonatomic, strong) NSMutableArray* testResults;
@property (nonatomic, strong) NSMutableArray* sdkTestResults;

@end

@implementation RTTestModel

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

- (void)dealloc
{
    [self.progressHUD removeFromSuperview];
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
        mIsLoading = YES;
        mStartDate = [NSDate date];
        
        NSString* type = [RevSDK operationMode] == kRSOperationModeOff ? @"Origin" : @"SDK";
        NSString* pass = [NSString stringWithFormat:@"Pass: %ld / %ld", mTestsCounter, mNumberOfTestsToPerform];
        NSString* text = [NSString stringWithFormat:@"%@ %@", type, pass];
        
        NSLog(@"Start %ld", mTestsCounter);
        
         UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressHUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
            self.progressHUD.mode = MBProgressHUDModeIndeterminate;
            self.progressHUD.labelText = text;
            self.progressHUD.removeFromSuperViewOnHide = YES;
        });
        
        if (self.loadStartedBlock)
        {
            self.loadStartedBlock();
        }
    }
}

- (void)loadFinished
{
    NSLog(@"Finish %ld", mTestsCounter);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressHUD hide:YES];
    });
    
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
