//
//  RevSDK.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RevSDK.h"
#import "RSURLProtocol.h"

@implementation RevSDK

+ (void)startWithSDKKey:(NSString *)aSDKKey
{
    NSLog(@"Start with key %@", aSDKKey);
    
    [NSURLProtocol registerClass:[RSURLProtocol class]];
}

@end