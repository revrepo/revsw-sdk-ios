//
//  RevSDK.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "RSLogVC.h"

#import "RevSDK.h"
#import "RSURLProtocol.h"

#import "Model.hpp"
#include "Utils.hpp"
#import "RSUtils.h"
#import "NSURLSessionConfiguration+RSUtils.h"
#import "DebugUsageTracker.hpp"

#include "TestConfigurationService.h"

@implementation RevSDK

static bool gIsInitialized = false;

static rs::TestConfigurationService* TestConfService = nullptr;

+ (void)startWithSDKKey:(NSString *)aSDKKey
{
    if(![[NSThread currentThread] isMainThread])
    {
        NSException *e = [NSException
                          exceptionWithName:@"RSInitializationException"
                          reason:@"*** This function can only be invoked from the main thread."
                          userInfo:nil];
        @throw e;
    }
    
    if  (!gIsInitialized)
    {
        [NSURLProtocol registerClass:[RSURLProtocol class]];
        rs::Model::instance()->initialize(rs::stdStringFromNSString(aSDKKey));
        
        gIsInitialized = true;
    }
    else
    {
        NSLog(@"SDK is already initialized.");
    }
}

+ (void)debug_setOperationMode:(RSOperationMode)aOperationMode
{
    rs::RSOperationModeInner innerMode;
    
    switch (aOperationMode)
    {
        case kRSOperationModeOff:
            innerMode = rs::kRSOperationModeInnerOff;
            break;
        case kRSOperationModeTransport:
            innerMode = rs::kRSOperationModeInnerTransport;
            break;
        case kRSOperationModeReport:
            innerMode = rs::kRSOperationModeInnerReport;
            break;
        case kRSOperationModeTransportAndReport:
            innerMode = rs::kRSOperationModeInnerTransportAndReport;
            break;
            
        default: break;
    }
    
    rs::Model::instance()->setOperationMode(innerMode);
}

+ (void)debug_enableTestMode
{
    TestConfService = new rs::TestConfigurationService(rs::Model::instance());
    TestConfService->init();
    rs::Model::instance()->debug_replaceConfigurationService(TestConfService);
}

+ (void)debug_disableTestMode
{
    rs::Model::instance()->debug_disableDebugMode();
    
    TestConfService = nullptr;
}

+ (void)debug_pushTestConifguration:(NSString *)aProtocolID mode:(RSOperationMode)aOperationMode
{
    assert(TestConfService);
    if (TestConfService)
    {
        rs::RSOperationModeInner innerMode;
        
        switch (aOperationMode)
        {
            case kRSOperationModeOff:
                innerMode = rs::kRSOperationModeInnerOff;
                break;
            case kRSOperationModeTransport:
                innerMode = rs::kRSOperationModeInnerTransport;
                break;
            case kRSOperationModeReport:
                innerMode = rs::kRSOperationModeInnerReport;
                break;
            case kRSOperationModeTransportAndReport:
                innerMode = rs::kRSOperationModeInnerTransportAndReport;
                break;
                
            default: break;
        }
        
        TestConfService->pushTestConfig(rs::stdStringFromNSString(aProtocolID), (int)innerMode);
    }
}

+ (RSOperationMode)operationMode
{
    rs::RSOperationModeInner innerMode = rs::Model::instance()->currentOperationMode();
    
    switch (innerMode)
    {
        case rs::kRSOperationModeInnerOff: return kRSOperationModeOff;
        case rs::kRSOperationModeInnerReport: return kRSOperationModeReport;
        case rs::kRSOperationModeInnerTransport: return kRSOperationModeTransport;
        case rs::kRSOperationModeInnerTransportAndReport: return kRSOperationModeTransportAndReport;
    }
}

+ (NSDictionary *)debug_getUsageStatistics
{
    const rs::DebugUsageTracker::Statistics &map =
    rs::Model::instance()->debug_usageTracker()->getUsageStatistics();
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for (const auto &it : map) {
        NSString *key = (0 == it.first.length()) ? (@"") : (@(it.first.c_str()));
        NSString *value = (0 == it.second.length()) ? (@"") : (@(it.second.c_str()));
        [dictionary setObject:value forKey:key];
    }
    
    return dictionary;
}

+ (void)debug_resetUsageStatistics
{
    rs::Model::instance()->debug_usageTracker()->reset();
}

+ (NSString *)debug_getLatestConfiguration
{
    return @(rs::Model::instance()->debug_usageTracker()->getLatestConfiguration().c_str());
}

+ (void)debug_forceConfigurationUpdate
{
    rs::Model::instance()->debug_forceReloadConfiguration();
}

+ (void)debug_showLogInViewController:(UIViewController*)aVC
{
    if (aVC == nil)
        return;
    
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:[RSLogVC createNew]];
    [aVC presentViewController:nc animated:YES completion:^{}];
}

@end
