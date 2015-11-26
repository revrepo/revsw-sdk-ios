//
//  RevSDK.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "RevSDK.h"
#import "RSURLProtocol.h"

#import "Model.hpp"

@implementation RevSDK

+ (void)startWithSDKKey:(NSString *)aSDKKey
{
    [NSURLProtocol registerClass:[RSURLProtocol class]];

    rs::Model::instance()->initialize();
    
    rs::Model::instance()->mCurrentMode = rs::kRSOperationModeInnerTransportAndReport;
}

+ (void)setOperationMode:(RSOperationMode)aOperationMode
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
    
    rs::Model::instance()->mCurrentMode = innerMode;
}

+ (RSOperationMode)operationMode
{
    rs::RSOperationModeInner innerMode = rs::Model::instance()->mCurrentMode;
    
    switch (innerMode)
    {
        case rs::kRSOperationModeInnerOff: return kRSOperationModeOff;
        case rs::kRSOperationModeInnerReport: return kRSOperationModeReport;
        case rs::kRSOperationModeInnerTransport: return kRSOperationModeTransport;
        case rs::kRSOperationModeInnerTransportAndReport: return kRSOperationModeTransportAndReport;
    }
}

@end