//
//  RevSDK.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

@import ObjectiveC.runtime;

#import "RevSDK.h"
#import "RSURLProtocol.h"

static NSArray* (*originalImplementation)();

static NSArray* customProtocolClasses()
{
    NSArray* originalProtocolClasses = originalImplementation();
    Class class                      = [RSURLProtocol class];
    NSMutableArray* protocolClasses  = [NSMutableArray arrayWithArray:originalProtocolClasses];

    if(![protocolClasses containsObject:class])
    {
       [protocolClasses addObject:class];
    }
    
    return protocolClasses;
}

static void swizzleProtocolClasses()
{
    Class class            = NSClassFromString(@"__NSCFURLSessionConfiguration");
    SEL selector           = @selector(protocolClasses);
    Method method          = class_getInstanceMethod(class, selector);
    originalImplementation = (NSArray* (*)())method_getImplementation(method);
    
    method_setImplementation(method, (IMP)customProtocolClasses);
}

@implementation RevSDK

+ (void)startWithSDKKey:(NSString *)aSDKKey
{
    [NSURLProtocol registerClass:[RSURLProtocol class]];
    swizzleProtocolClasses();
}

@end