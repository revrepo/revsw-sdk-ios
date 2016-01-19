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

#import "RTUtils.h"


const CGFloat kRTRowHeight = 50.f;
NSString* const kRTSDKLabelTextKey = @"kRTSDKLabelTextKey";

@implementation RTUtils

+ (NSString*)stringOfSize:(NSUInteger)aSize
{
    NSMutableString* string = [NSMutableString string];
    
    for (NSUInteger i = 0; i < aSize; i++)
    {
        [string appendString:@"x"];
    }
    
    return string;
}

+ (NSData *)jsonDataOfSize:(NSUInteger)aSize
{
    const NSUInteger kJsonDiff = 4;
    NSString* string = [self stringOfSize:aSize - kJsonDiff];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:@[string]
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

+ (NSData *)xmlDataOfSize:(NSUInteger)aSize
{
     const NSUInteger kXmlDiff = 191;
     NSString* string = [self stringOfSize:aSize - kXmlDiff];
    
     NSData* data = [NSPropertyListSerialization dataWithPropertyList:string
                                                               format:NSPropertyListXMLFormat_v1_0
                                                              options:0
                                                                error:nil];
    return data;
}

@end
