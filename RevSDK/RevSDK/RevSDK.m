//
//  RevSDK.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RevSDK.h"
#import "RSURLProtocol.h"
#import "NSURLSessionConfiguration+RSUtils.h"

@implementation RevSDK

+ (void)startWithSDKKey:(NSString *)aSDKKey
{
    [NSURLProtocol registerClass:[RSURLProtocol class]];
    [NSURLSessionConfiguration rs_swizzleProtocolClasses];
}

@end