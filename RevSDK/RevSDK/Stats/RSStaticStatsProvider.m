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

#import <Foundation/Foundation.h>
#import "RSStaticStatsProvider.h"
#include <mach/mach_host.h>

unsigned int countCores()
{
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount;
    
    infoCount = HOST_BASIC_INFO_COUNT;
    host_info( mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount ) ;
    
    return (unsigned int)(hostInfo.max_cpus);
}

@interface RSStaticStatsProvider()
{
    int mCores; 
}
@end


@implementation RSStaticStatsProvider

@synthesize cores = mCores;

+ (RSStaticStatsProvider*)sharedService
{
    static RSStaticStatsProvider* mInstance = nil;
    static dispatch_once_t mToken;
    dispatch_once(&mToken, ^{
        mInstance = [[RSStaticStatsProvider alloc] init];
    });
    return mInstance;
}

-(id)init
{
    if (self = [super init])
    {
        mCores = countCores();
    }
    return self;
}

@end