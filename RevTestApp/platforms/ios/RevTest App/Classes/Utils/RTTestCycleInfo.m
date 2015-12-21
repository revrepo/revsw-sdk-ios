//
//  RTTestCycleInfo.m
//  RevTest App
//
//  Created by Vlad Joss on 21.12.15.
//
//

#import "RTTestCycleInfo.h"

@implementation RTTestCycleInfo

- (BOOL)valid
{
    BOOL result = NO;
    if ([self.method isEqualToString:@"GET"])
    {
        result = [self.edgeRcvdChecksum isEqualToString:self.asisRcvdChecksum];
        result = result && [self.errorAsIs isEqual:self.errorEdge];
    }
    else
    {
        result = [self.asisSentChecksum isEqualToString:self.asisRcvdChecksum];
        result = result && [self.asisRcvdChecksum isEqualToString:self.edgeSentChecksum];
        result = result && [self.asisRcvdChecksum isEqualToString:self.edgeRcvdChecksum];
        result = result && [self.errorAsIs isEqual:self.errorEdge];
    }
    
    return result;
}

@end
