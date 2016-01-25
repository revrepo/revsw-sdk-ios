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

#import "NSArray+Stats.h"
#import "math.h"

#define SHOULD_CONSIDER_MIN_AND_MAX_VALUES 0

#if SHOULD_CONSIDER_MIN_AND_MAX_VALUES
#define OPERATION_ARRAY self
#else
#define OPERATION_ARRAY (self.count < 5 ? self : [[self sortedArrayUsingSelector:@selector(compare:)] subarrayWithRange:NSMakeRange(1, [self count] - 2)])
#endif

@implementation NSArray (Statistics)

- (NSNumber *)median
{
    if (self.count == 0)
    {
        return @0;
    }
    
    if (self.count == 1)
    {
        return self.firstObject;
    }
    
    NSArray* operationArray = OPERATION_ARRAY;
    
    if (operationArray.count == 0)
    {
        return @0;
    }
    
    return [[operationArray sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[operationArray count] / 2];
}

- (NSNumber *)meanValue
{
    if (self.count == 0)
    {
        return @0;
    }
    
    double runningTotal = 0.0;
    
    for (NSNumber *number in self)
    {
        runningTotal += [number doubleValue];
    }
    
    return [NSNumber numberWithDouble:(runningTotal / [self count])];
}

- (NSNumber *)standardDeviation
{
    if (self.count == 0 || self.count == 1)
    {
        return @0;
    }
    
    NSArray* operationArray = OPERATION_ARRAY;
    
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
    if (self.count == 0)
    {
        return @0;
    }
    
    if (self.count == 1)
    {
        return self.firstObject;
    }
    
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

- (NSArray *)arrayByRemovingNAN
{
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(NSNumber* number, NSDictionary* bindings){
    
        return  !isnan(number.doubleValue);
    
    }];
    
    return [self filteredArrayUsingPredicate:predicate];
}

@end
