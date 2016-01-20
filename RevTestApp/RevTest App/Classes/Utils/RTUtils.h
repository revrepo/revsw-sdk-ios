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
