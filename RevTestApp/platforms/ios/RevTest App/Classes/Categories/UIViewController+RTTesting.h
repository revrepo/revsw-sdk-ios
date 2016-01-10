//
//  UIViewController+RTTesting.h
//  RevTest App
//
//  Created by Andrey Chernukha on 12/9/15.
//
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@class RTTestModel;

@interface UIViewController (RTTesting)

@property (nonatomic, strong) MBProgressHUD* progressHUD;
@property (nonatomic, strong) RTTestModel* testModel;
@property (nonatomic, copy) void (^loadStartedBlock)();
@property (nonatomic, copy) void (^restartBlock)();
@property (nonatomic, copy) void (^completionBlock)();
@property (nonatomic, copy) void (^loadFinishedBlock)();
@property (nonatomic, copy) void (^cancelBlock)();

- (void)setBaseURL:(NSURL*)aBaseURL;
- (void)showHudWithText:(NSString *)aText;
- (void)hideHud;

- (void)initializeTestModel;
- (void)setNumberOfTests:(NSUInteger)aNumberOfTests;
- (void)setWhiteListOption:(BOOL)aOn;
- (void)startTesting;
- (BOOL)shouldStartLoadingRequest:(NSURLRequest *)aURLRequest;
- (void)loadStarted;
- (void)loadFinished:(NSInteger) aCode;

- (void)stepStarted;
- (void)stepFinished:(bool)result;

@end
