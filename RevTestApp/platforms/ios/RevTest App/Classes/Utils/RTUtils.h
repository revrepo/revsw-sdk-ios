//
//  RTUtils.h
//  RevTest App
//
//  Created by Andrey Chernukha on 12/8/15.
//
//

#import <Foundation/Foundation.h>

#define RTPerformBlockOnQueue(queue, block, ...)\
if (block)\
{\
dispatch_async(queue, ^{\
block(__VA_ARGS__);\
});\
}\

#define RTPerformBlockOnMainQueue(block, ...)\
RTPerformBlockOnQueue(dispatch_get_main_queue(), block, __VA_ARGS__)

extern const CGFloat kRTRowHeight;

extern NSString* const kRTSDKLabelTextKey;

@interface RTUtils : NSObject

+ (NSData *)jsonDataOfSize:(NSUInteger)aSize;
+ (NSData *)xmlDataOfSize:(NSUInteger)aSize;

@end
