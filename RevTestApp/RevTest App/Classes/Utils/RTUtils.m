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

NSString* const kRTRequestLoopDidFinishNotification = @"kRTRequestLoopDidFinishNotification";
NSString* const kRTSDKLabelTextKey = @"kRTSDKLabelTextKey";
NSString* const kRTTitleKey = @"kRTTitleKey";
NSString* const kRTTextsKey = @"kRTTextsKey";
NSString* const kRTResultKey = @"kRTResultKey";

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

+ (NSString *)htmlStringFromTestResults:(NSArray *)aTestResults dictionaries:(NSArray *)aDictionaries title:(NSString *)aTitle testType:(NSString*)aTestType
{
    NSMutableString* htmlString = [NSMutableString stringWithFormat:@"<html><header><title></title></header><body>Test type: %@<br/>%@<table><tr><td> </td>",aTestType, aTitle];
    
    RTIterationResult* iterationResult = aTestResults.firstObject;
    NSArray* iterationTestResults  = iterationResult.testResults;
    
    for (RTTestResult* testResult in iterationTestResults)
    {
        NSString* name = testResult.testName;
        NSString* htmlName = [NSString stringWithFormat:@"<td>%@</td>", name];
        [htmlString appendString:htmlName];
    }
    
    [htmlString appendString:@"</tr>"];
    
    [aTestResults enumerateObjectsUsingBlock:^(RTIterationResult* iterationResult, NSUInteger index, BOOL* stop){
        
        [htmlString appendString:@"<tr>"];
        
        NSArray* iterationTestResults  = iterationResult.testResults;
        
        NSString* numberString  = [NSString stringWithFormat:@"<td>%lu.</td>", index + 1];
        [htmlString appendString:numberString];
        
        [iterationTestResults enumerateObjectsUsingBlock:^(RTTestResult* testResult, NSUInteger index, BOOL* stop){
            
            NSString* durationString = [NSString stringWithFormat:@"<td>%@</td>", testResult.durationString];
            [htmlString appendString:durationString];
        }];
        
        [htmlString appendString:@"</tr>"];
        [htmlString appendString:@"<tr>"];
        
        NSString* nString  = [NSString stringWithFormat:@"<td>  </td>"];
        [htmlString appendString:nString];
        
        [iterationTestResults enumerateObjectsUsingBlock:^(RTTestResult* testResult, NSUInteger index, BOOL* stop){
            
            NSString* dataLengthString = [NSString stringWithFormat:@"<td>%@</td>", testResult.dataLengthString];
            [htmlString appendString:dataLengthString];
        }];
        
        [htmlString appendString:@"</tr>"];
    }];
    
    [htmlString appendString:@"<tr><td>-</td><td>-</td><td>-</td><td>-</td></tr>"];
    
    for (NSDictionary* dictionary in aDictionaries)
    {
        [htmlString appendString:@"<tr>"];
        
        NSString* title = dictionary[kRTTitleKey];
        NSString* htmlTitle = [NSString stringWithFormat:@"<td>%@</td>", title];
        [htmlString appendString:htmlTitle];
        
        NSArray* texts = dictionary[kRTTextsKey];
        
        for (NSString* text in texts)
        {
            NSString* htmlText = [NSString stringWithFormat:@"<td>%@</td>", text];
            [htmlString appendString:htmlText];
        }
        
        [htmlString appendString:@"</tr>"];
    }

    [htmlString appendString:@"</table></body></html>"];
    
    return htmlString;
}

@end
