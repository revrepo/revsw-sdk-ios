//
//  RevSDKPrivate.h
//  RevSDK
//
//  Created by Andrey Chernukha on 1/15/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import "RevSDK.h"

#ifndef RevSDKPrivate_h
#define RevSDKPrivate_h

typedef enum
{
    kRSOperationModeOff,
    kRSOperationModeTransport,
    kRSOperationModeReport,
    kRSOperationModeTransportAndReport
}RSOperationMode;

@class UIViewController;

@interface RevSDK (PrivateInterface)

+ (void)debug_pushTestConifguration:(NSString*)aProtocolID mode:(RSOperationMode)aOperationMode;
+ (void)debug_enableTestMode;
+ (void)debug_disableTestMode;
+ (RSOperationMode)operationMode;

+ (NSDictionary *)debug_getUsageStatistics;
+ (void)debug_resetUsageStatistics;
+ (NSString *)debug_getLatestConfiguration;
+ (void)debug_forceConfigurationUpdate;
+ (void)debug_showLogInViewController:(UIViewController*)aVC;
+ (void)debug_turnOnDebugBanners;

@end

#endif /* RevSDKPrivate_h */
