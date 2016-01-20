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

#import <Foundation/Foundation.h>
#import "RTTestResult.h"
#import "RTTestCase.h"

@interface RTTestModel : NSObject

@property (nonatomic, assign) BOOL shouldLoad;
@property (nonatomic, copy) void (^loadStartedBlock)(NSString*);
@property (nonatomic, copy) void (^loadFinishedBlock)(void);
@property (nonatomic, copy) void (^restartBlock)(void);
@property (nonatomic, copy) void (^completionBlock)(NSArray*);
@property (nonatomic, copy) void (^cancelBlock)();

- (void)start;
- (void)setWhiteListOption:(BOOL)aOn;
- (void)setNumberOfTests:(NSUInteger)aNumberOfTests;

- (void)loadFinished:(NSInteger)aResult;
- (void)loadStarted;

- (void)stepStarted;
- (void)stepFinished;

@end
