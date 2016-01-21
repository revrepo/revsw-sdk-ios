/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
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


#import "RTTestResult.h"

static BOOL shouldReportDataInMB = NO;

@implementation RTTestResult

+ (void)setShouldReportDataInMB:(BOOL)aShouldReportDataInMB
{
    shouldReportDataInMB = aShouldReportDataInMB;
}

- (NSString *)durationString
{
    return [NSString stringWithFormat:@"%.3f", _duration];
}

- (NSString *)dataLengthString
{
    CGFloat dataLength = shouldReportDataInMB ? _dataLength / 1024.0 : _dataLength / 1024.0;
    
    return [NSString stringWithFormat:@"%.1f", dataLength];
}

- (NSString *)wholeString
{
    return [NSString stringWithFormat:@"%@\n(%@)", self.durationString, self.dataLengthString];
}

- (NSString *)plainWholeString
{
    return [self.wholeString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (NSString *)nameString
{
    NSString* dataSizeNotation = shouldReportDataInMB ? @"KB" : @"KB";
    
    return [NSString stringWithFormat:@"%@(%@)", _testName, dataSizeNotation];
}

- (NSString *)description
{
    return self.dataLengthString;
}

@end