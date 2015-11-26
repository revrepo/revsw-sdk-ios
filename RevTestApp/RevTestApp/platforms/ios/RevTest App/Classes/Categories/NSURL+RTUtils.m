//
//  NSURL+RTUtils.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "NSURL+RTUtils.h"

@implementation NSURL (RTUtils)

- (BOOL)isValid
{
    return self.scheme.length && self.host.length;
}

@end
