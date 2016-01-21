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
#import "RTIterationResult.h"
#import "RTTestResult.h"

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

+ (NSString *)formattedStringFromTestResults:(NSArray *)aTestResults
{
    assert(aTestResults);
    assert(aTestResults.count);
    
    NSString* startString = [@" " stringByPaddingToLength:5
                                               withString:@" "
                                          startingAtIndex:0];
    
    NSMutableString* formattedString = [NSMutableString stringWithString:startString];
    
    RTIterationResult* iterationResult = aTestResults.firstObject;
    NSArray* iterationTestResults  = iterationResult.testResults;
    
    for (RTTestResult* testResult in iterationTestResults)
    {
        NSString* paddedString = [testResult.nameString stringByPaddingToLength:15
                                                                   withString:@" "
                                  
                                                              startingAtIndex:0];
        [formattedString appendString:paddedString];
    }

    [formattedString appendString:@"\n"];
    
    [aTestResults enumerateObjectsUsingBlock:^(RTIterationResult* iterationResult, NSUInteger index, BOOL* stop){
    
        NSArray* iterationTestResults  = iterationResult.testResults;
       
        NSString* numberString  = [NSString stringWithFormat:@"%ld.", index + 1];
        NSString* newLineString = [numberString stringByPaddingToLength:5
                                                             withString:@" "
                                                        startingAtIndex:0];
        [formattedString appendString:newLineString];
        
        [iterationTestResults enumerateObjectsUsingBlock:^(RTTestResult* testResult, NSUInteger index, BOOL* stop){
        
            NSString* paddedString = [testResult.durationString stringByPaddingToLength:20 + index
                                                                             withString:@" "
                                                                        startingAtIndex:0];
            [formattedString appendString:paddedString];
            
        }];
        
        [formattedString appendString:@"\n"];
        
        newLineString = [@"  " stringByPaddingToLength:6
                                            withString:@" "
                                       startingAtIndex:0];
        
        [formattedString appendString:newLineString];
        
        [iterationTestResults enumerateObjectsUsingBlock:^(RTTestResult* testResult, NSUInteger index, BOOL* stop){
        
            NSString* paddedString = [testResult.dataLengthString stringByPaddingToLength:19 + index
                                                                               withString:@" "
                                                                          startingAtIndex:0];
            [formattedString appendString:paddedString];
        }];
        
        [formattedString appendString:@"\n"];
    }];
    
    return formattedString;
}

@end
