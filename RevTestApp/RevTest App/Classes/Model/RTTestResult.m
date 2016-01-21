//
//  TestResult.m
//  RevTest App
//
//  Created by Vlad Joss on 06.01.16.
//
//

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