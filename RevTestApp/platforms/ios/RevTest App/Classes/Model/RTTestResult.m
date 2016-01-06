//
//  TestResult.m
//  RevTest App
//
//  Created by Vlad Joss on 06.01.16.
//
//

#import "RTTestResult.h"

@implementation RTTestResult

- (NSString *)durationString
{
    return [NSString stringWithFormat:@"%.1f", _duration];
}

- (NSString *)dataLengthString
{
    return [NSString stringWithFormat:@"%.1f", _dataLength];
}

- (NSString *)wholeString
{
    return [NSString stringWithFormat:@"%@(%@)", self.durationString, self.dataLengthString];
}

@end