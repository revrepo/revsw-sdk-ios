//
//  RSTestModel.h
//  RevTest App
//
//  Created by Andrey Chernukha on 12/4/15.
//
//

#import <Foundation/Foundation.h>

@interface RSTestModel : NSObject

@property (nonatomic, copy) void (^loadStartedBlock)(void);
@property (nonatomic, copy) void (^loadFinishedBlock)(void);
@property (nonatomic, copy) void (^restartBlock)(void);
@property (nonatomic, copy) void (^completionBlock)(NSArray*, NSArray*);

- (void)start;
- (void)setWhiteListOption:(BOOL)aOn;
- (void)setNumberOfTests:(NSUInteger)aNumberOfTests;
- (void)loadStarted;
- (void)loadFinished;

@end
