//
//  NSURLSessionConfiguration+RSUtils.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

@import ObjectiveC.runtime;

#import "NSURLSessionConfiguration+RSUtils.h"
#import "RSURLProtocol.h"

static NSArray* (*originalImplementation)();

@implementation NSURLSessionConfiguration (RSUtils)

- (NSArray *)rs_protocolClasses
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

+ (void)rs_swizzleProtocolClasses
{
    Class class                = NSClassFromString(@"__NSCFURLSessionConfiguration");
    SEL originalSelector       = @selector(protocolClasses);
    Method originalMethod      = class_getInstanceMethod(class, originalSelector);
    originalImplementation     = (NSArray* (*)())method_getImplementation(originalMethod);
    SEL swizzledSelector       = @selector(rs_protocolClasses);
    Method swizzledMethod      = class_getInstanceMethod([NSURLSessionConfiguration class], swizzledSelector);
    IMP swizzledImplementation = method_getImplementation(swizzledMethod);
    
    method_setImplementation(originalMethod, swizzledImplementation);
}

@end
