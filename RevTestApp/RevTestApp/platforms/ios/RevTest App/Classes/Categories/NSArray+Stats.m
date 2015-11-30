//
//  NSArray+Stats.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "NSArray+Stats.h"

@implementation NSArray (Statistics)

- (id)median
{
    return [[self sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[self count] / 2];
}

@end
