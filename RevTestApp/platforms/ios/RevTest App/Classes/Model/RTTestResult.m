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
    return [NSString stringWithFormat:@"%.3f", _duration];
}

- (NSString *)dataLengthString
{
    return [NSString stringWithFormat:@"%.1f", _dataLength];
}

- (NSString *)wholeString
{
    return [NSString stringWithFormat:@"%@ (%@)", self.durationString, self.dataLengthString];
}

- (NSString *)nameString
{
    return [NSString stringWithFormat:@"%@(KB)", _testName];
}

- (NSString *)description
{
    return self.dataLengthString;
}

@end