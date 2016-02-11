//
//  StatsUploadTester.h
//  RevTest App
//
//  Created by Andrey Chernukha on 2/11/16.
//
//

#import <Foundation/Foundation.h>

@interface RTStatsUploadTester : NSObject

+ (instancetype)defaultTester;
- (instancetype)initWithNumberOfRequests:(NSUInteger)aRequests numberOfPasses:(NSUInteger)aPasses URLString:(NSString *)aURLString;
- (void)start;

@end
