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
    
    rs::Model::instance()->mCurrentMode = kRSOperationModeInnerTransportAndReport;
}

+ (void)setOperationMode:(RSOperationMode)aOperationMode
{
    RSOperationModeInner innerMode;
    
    switch (aOperationMode)
    {
        case kRSOperationModeOff:
            innerMode = kRSOperationModeInnerOff;
            break;
        case kRSOperationModeTransport:
            innerMode = kRSOperationModeInnerTransport;
            break;
        case kRSOperationModeReport:
            innerMode = kRSOperationModeInnerReport;
            break;
        case kRSOperationModeTransportAndReport:
            innerMode = kRSOperationModeInnerTransportAndReport;
            break;
            
        default: break;
    }
    
    rs::Model::instance()->mCurrentMode = innerMode;
}

@end