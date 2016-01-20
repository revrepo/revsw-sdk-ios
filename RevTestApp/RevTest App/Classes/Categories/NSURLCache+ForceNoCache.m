//
//  NSURLCache+ForceNoCache.m
//  RevTest App
//
//  Created by Peter Rudenko on 12.01.16.
//
//

#import "NSURLCache+ForceNoCache.h"

@implementation NSURLCache (ForceNoCache)

- (NSCachedURLResponse*)cachedResponseForRequest:(NSURLRequest*)request
{
    return nil;
}

@end
