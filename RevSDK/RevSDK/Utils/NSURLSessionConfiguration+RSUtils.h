//
//  NSURLSessionConfiguration+RSUtils.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionConfiguration (RSUtils)

+ (void)rs_swizzleProtocolClasses;

@end
