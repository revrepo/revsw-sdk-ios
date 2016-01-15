/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

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
