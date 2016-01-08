//
//  RTUtils.m
//  RevTest App
//
//  Created by Andrey Chernukha on 12/8/15.
//
//

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
