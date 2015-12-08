//
//  RTUtils.h
//  RevTest App
//
//  Created by Andrey Chernukha on 12/8/15.
//
//

#import <Foundation/Foundation.h>

@interface RTUtils : NSObject

+ (NSData *)jsonDataOfSize:(NSUInteger)aSize;
+ (NSData *)xmlDataOfSize:(NSUInteger)aSize;

@end
