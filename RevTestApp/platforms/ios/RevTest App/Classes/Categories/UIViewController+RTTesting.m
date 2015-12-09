//
//  UIViewController+RTTesting.m
//  RevTest App
//
//  Created by Andrey Chernukha on 12/9/15.
//
//

#import "objc/runtime.h"

#import "MBProgressHUD.h"

#import "UIViewController+RTTesting.h"
#import "NSURL+RTUTils.h"

#import "RTContainerViewController.h"
#import "RTTestModel.h"
#import "RTUtils.h"


@implementation UIViewController (RTTesting)

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
        RTPerformBlockOnMainQueue(weakSelf.loadStartedBlock);
        [weakSelf showHudWithText:aText];
    };
    
    self.testModel.loadFinishedBlock = ^{
        RTPerformBlockOnMainQueue(weakSelf.loadFinishedBlock);
        [weakSelf hideHud];
    };
    
    self.testModel.restartBlock = ^{
        RTPerformBlockOnMainQueue(weakSelf.restartBlock);
    };
    
    self.testModel.completionBlock = ^(NSArray* aTestResults, NSArray* aSdkTestResults){
        RTPerformBlockOnMainQueue(weakSelf.completionBlock);
        [weakSelf goToStatsWithTestResults:aTestResults sdkResults:aSdkTestResults];
    };
}

- (void)goToStatsWithTestResults:(NSArray *)aTestResults sdkResults:(NSArray *)aSdkTestResults
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        RTContainerViewController* containerViewController = [RTContainerViewController new];
        containerViewController.directResults              = aTestResults;
        containerViewController.sdkResults                 = aSdkTestResults;
        
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

- (void)loadFinished
{
    [self.testModel loadFinished];
}

- (BOOL)shouldStartLoadingRequest:(NSURLRequest *)aURLRequest
{
    return aURLRequest.URL.isValid && self.testModel.shouldLoad;
}

@end
