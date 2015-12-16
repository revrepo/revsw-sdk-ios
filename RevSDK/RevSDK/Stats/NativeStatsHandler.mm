//
//  NativeStatsHandler.m
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sys/utsname.h>

#import "NativeStatsHandler.h"
#include "Data.hpp"
#include "RSUtils.h"

static NSString* const kRSDeviceNameKey = @"kRSDeviceNameKey";
static NSString* const kRSOSVersionKey = @"kRSOSVersionKey";

namespace rs
{
    NSString* deviceName()
    {
        struct utsname systemInfo;
        uname(&systemInfo);
        
        return [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
    }
    
    NSString* osVersion()
    {
        return [UIDevice currentDevice].systemVersion;
    }
    
    Data NativeStatsHandler::statsData()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        
        statsDictionary[kRSDeviceNameKey] = deviceName();
        statsDictionary[kRSOSVersionKey]  = osVersion();
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:statsDictionary
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
        Data rsData = dataFromNSData(nsData);
        
        return rsData;
    }
}