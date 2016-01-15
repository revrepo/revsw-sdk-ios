//
//  NSURLCache+ForceNoCache.h
//  RevTest App
//
//  Created by Peter Rudenko on 12.01.16.
//
//

#import <Foundation/Foundation.h>

@interface NSURLCache (ForceNoCache)

- (NSCachedURLResponse*)cachedResponseForRequest:(NSURLRequest*)request;

@end
