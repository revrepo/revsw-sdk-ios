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

#import "objc/runtime.h"

#import "MBProgressHUD.h"

#import "UIViewController+RTTesting.h"
#import "NSURL+RTUTils.h"

#import "RTContainerViewController.h"
#import "RTTestModel.h"
#import "RTUtils.h"


@implementation UIViewController (RTTesting)

- (void)setCancelBlock:(void (^)())aCancelBlock
{
    objc_setAssociatedObject(self, @selector(cancelBlock), aCancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)())cancelBlock
{
    return objc_getAssociatedObject(self, @selector(cancelBlock));
}

- (void)setLoadFinishedBlock:(void (^)())aLoadFinishedBlock
{
    objc_setAssociatedObject(self, @selector(loadFinishedBlock), aLoadFinishedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)())loadFinishedBlock
{
    return objc_getAssociatedObject(self, @selector(loadFinishedBlock));
}

- (void)setCompletionBlock:(void (^)())aCompletionBlock
{
    objc_setAssociatedObject(self, @selector(completionBlock), aCompletionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)())completionBlock
{
    return objc_getAssociatedObject(self, @selector(completionBlock));
}

- (void)setRestartBlock:(void (^)())aRestartBlock
{
    objc_setAssociatedObject(self, @selector(restartBlock), aRestartBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)())restartBlock
{
    return objc_getAssociatedObject(self, @selector(restartBlock));
}

- (void)setLoadStartedBlock:(void (^)())aLoadStartedBlock
{
    objc_setAssociatedObject(self, @selector(loadStartedBlock), aLoadStartedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)())loadStartedBlock
{
    return objc_getAssociatedObject(self, @selector(loadStartedBlock));
}

- (void)setTestModel:(RTTestModel *)aTestModel
{
    objc_setAssociatedObject(self, @selector(testModel), aTestModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RTTestModel *)testModel
{
    return objc_getAssociatedObject(self, @selector(testModel));
}

- (void)setProgressHUD:(MBProgressHUD *)aProgressHUD
{
    objc_setAssociatedObject(self, @selector(progressHUD), aProgressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setNumberOfTests:(NSUInteger)aNumberOfTests
{
    [self.testModel setNumberOfTests:aNumberOfTests];
}

- (void)setWhiteListOption:(BOOL)aOn
{
    [self.testModel setWhiteListOption:aOn];
}

- (void)initializeTestModel
{
    __weak UIViewController* weakSelf = self;
    
    self.testModel = [RTTestModel new];
    
    self.testModel.loadStartedBlock = ^(NSString* aText){
        //RTPerformBlockOnMainQueue(weakSelf.loadStartedBlock);
        [weakSelf hideHud];
        [weakSelf showHudWithText:aText];
    };
    
    self.testModel.loadFinishedBlock = ^{
        RTPerformBlockOnMainQueue(weakSelf.loadFinishedBlock);
    };
    
    self.testModel.restartBlock = ^{
        RTPerformBlockOnMainQueue(weakSelf.restartBlock);
    };
    
    self.testModel.completionBlock = ^(NSArray* aTestResults){
        RTPerformBlockOnMainQueue(weakSelf.completionBlock);
        [weakSelf goToStatsWithTestResults:aTestResults];
        [weakSelf hideHud];
    };
    
    self.testModel.cancelBlock = ^(NSInteger aCode){
        RTPerformBlockOnMainQueue(weakSelf.cancelBlock);
        [weakSelf loadFinished:aCode];
    };
}

- (void)goToStatsWithTestResults:(NSArray *)aTestResults
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
       // NSArray* classNames = @[@"RTNativeMobileViewController", @"RTPhoneGapViewController", @"RTMobileWebViewController"];
        //NSArray* labelTexts = @[@"RevSDK", @"RevSDK", @"RevAPM"];
        
        //NSUInteger index    = [classNames indexOfObject:NSStringFromClass([self class])];
        //NSString* labelText = labelTexts[index];
        
        //NSDictionary* userInfo = @{kRTSDKLabelTextKey : labelText};
        
        RTContainerViewController* containerViewController = [RTContainerViewController new];
        containerViewController.testResults                = aTestResults;
        
        [self.navigationController pushViewController:containerViewController animated:YES];
    });
}

- (MBProgressHUD *)progressHUD
{
    return objc_getAssociatedObject(self, @selector(progressHUD));
}

- (void)showHudWithText:(NSString *)aText
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.labelText = aText;
        self.progressHUD.removeFromSuperViewOnHide = YES;
    });
}

- (void)hideHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressHUD hide:YES];
    });
}

- (void)startTesting
{
    [self.testModel start];
}

- (void)loadStarted
{
    [self.testModel loadStarted];
}

- (void)loadFinished:(NSInteger) aCode
{
    [self.testModel loadFinished:aCode];
}

- (void)stepStarted
{
    [self.testModel stepStarted];
}

//- (void)stepFinished:(bool)result
//{
//    [self.testModel stepFinished:result];
//}

- (BOOL)shouldStartLoadingRequest:(NSURLRequest *)aURLRequest
{
    return aURLRequest.URL.isValid && self.testModel.shouldLoad;
}

@end
