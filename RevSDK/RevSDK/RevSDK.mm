//
//  RevSDK.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RevSDK.h"
#import "RSURLProtocol.h"

#import "Model.hpp"
#include <jsoncpp/json/json.h>

@implementation RevSDK

+ (void)startWithSDKKey:(NSString *)aSDKKey
{
    [NSURLProtocol registerClass:[RSURLProtocol class]];
    
    rs::Model::instance()->initialize();
}

@end