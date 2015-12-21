//
//  RSTestModel.h
//  RevTest App
//
//  Created by Andrey Chernukha on 12/4/15.
//
//

#import <Foundation/Foundation.h>

@interface RTTestModel : NSObject

@property (nonatomic, assign) BOOL shouldLoad;
@property (nonatomic, copy) void (^loadStartedBlock)(NSString*);
@property (nonatomic, copy) void (^loadFinishedBlock)(void);
@property (nonatomic, copy) void (^restartBlock)(void);
@property (nonatomic, copy) void (^completionBlock)(NSArray*, NSArray*, NSArray*, NSArray*, NSArray*);
@property (nonatomic, copy) void (^cancelBlock)();

- (void)start;
- (void)setWhiteListOption:(BOOL)aOn;
- (void)setNumberOfTests:(NSUInteger)aNumberOfTests;

- (void)loadFinished;
- (void)loadStarted;

- (void)stepStarted;
- (void)stepFinished:(bool)withSuccess;

@end
