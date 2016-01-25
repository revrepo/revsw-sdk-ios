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

#import <UIKit/UIKit.h>

@class PickerView;
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
@property (nonatomic, copy) NSString* urlString;

- (void)showHudWithText:(NSString *)aText;
- (void)hideHud;

- (void)initializeTestModel:(NSString*)aTestType;
- (void)setNumberOfTests:(NSUInteger)aNumberOfTests;
- (void)setWhiteListOption:(BOOL)aOn;
- (void)startTesting;
- (BOOL)shouldStartLoadingRequest:(NSURLRequest *)aURLRequest;
- (void)loadStarted:(NSString*) aUrlString;
- (void)loadFinished:(NSInteger) aCode;

- (void)stepStarted;
//- (void)stepFinished:(bool)result;

- (void)stopTimer;

- (void)showHistoryPickerView:(NSArray*)dataArray;
- (void)hideHistoryPickerView;

@end
