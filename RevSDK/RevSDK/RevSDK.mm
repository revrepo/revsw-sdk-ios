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

#import "RevSDK.h"
#import "RSURLProtocol.h"

#import "Model.hpp"
#import "RSUtils.h"
#import "NSURLSessionConfiguration+RSUtils.h"

@implementation RevSDK

static bool gIsInitialized = false;

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

+ (void)debug_stopConfigurationUpdate
{
    rs::Model::instance()->stopConfigurationUpdate();
}

+ (void)debug_resumeConfigurationUpdate
{
    rs::Model::instance()->resumeConfigurationUpdate();
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

+ (void)setWhiteListOption:(BOOL)aOn
{
   rs::Model::instance()->switchWhiteListOption(aOn);
}

@end