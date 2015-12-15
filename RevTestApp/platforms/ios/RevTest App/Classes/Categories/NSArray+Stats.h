//
//  NSArray+Stats.h
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (Statistics)

- (NSNumber *)median;
- (NSNumber *)standardDeviation;
- (NSNumber *)expectedValue;

@end
