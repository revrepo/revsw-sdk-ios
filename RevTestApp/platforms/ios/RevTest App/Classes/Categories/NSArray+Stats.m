//
//  NSArray+Stats.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "NSArray+Stats.h"

#define SHOULD_CONSIDER_MIN_AND_MAX_VALUES 0

#if SHOULD_CONSIDER_MIN_AND_MAX_VALUES
#define OPERATION_ARRAY self
#else
#define OPERATION_ARRAY [[self sortedArrayUsingSelector:@selector(compare:)] subarrayWithRange:NSMakeRange(1, [self count] - 2)]
#endif

@implementation NSArray (Statistics)

- (NSNumber *)median
{
     NSArray* operationArray = OPERATION_ARRAY;
    
    return [[operationArray sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[operationArray count] / 2];
}

- (NSNumber *)meanValue
{
    double runningTotal = 0.0;
    
    for (NSNumber *number in self)
    {
        runningTotal += [number doubleValue];
    }
    
    return [NSNumber numberWithDouble:(runningTotal / [self count])];
}

- (NSNumber *)standardDeviation
{
    NSArray* operationArray = OPERATION_ARRAY;
    
    if(![operationArray count]) return nil;
    
    double mean = [[operationArray meanValue] doubleValue];
    double sumOfSquaredDifferences = 0.0;
    
    for(NSNumber *number in operationArray)
    {
        double valueOfNumber     = [number doubleValue];
        double difference        = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    return [NSNumber numberWithDouble:sqrt(sumOfSquaredDifferences / [operationArray count])];
}

- (NSNumber *)expectedValue
{
     NSArray* operationArray = OPERATION_ARRAY;
     CGFloat  ratio          = 1.0f / operationArray.count;
     CGFloat expectedValue   = 0.0f;
    
     for (NSNumber* number in operationArray)
     {
         CGFloat value = number.floatValue;
         expectedValue += value * ratio;
     }
    
    return @(expectedValue);
}

@end
