//
//  RTRequestTestLoop.h
//  RevTest App
//
//  Created by Andrey Chernukha on 2/3/16.
//
//

#import <Foundation/Foundation.h>

@interface RTRequestTestLoop : NSObject

+ (instancetype)defaultTestLoop;
- (instancetype)initWithDomains:(NSArray*)aDomains
                  numberOfTests:(NSUInteger)aNumberOfTests
             numberOfFullPasses:(NSUInteger)aNumberOfFullPasses;
- (void)start;

@end
