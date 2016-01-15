//
//  RevSDK.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
//! Project version number for RevSDK.
FOUNDATION_EXPORT double RevSDKVersionNumber;

//! Project version string for RevSDK.
FOUNDATION_EXPORT const unsigned char RevSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <RevSDK/PublicHeader.h>

#import <RevSDK/RSPublicConsts.h>


typedef enum
{
    kRSOperationModeOff,
    kRSOperationModeTransport,
    kRSOperationModeReport,
    kRSOperationModeTransportAndReport
}RSOperationMode;

@class UIViewController;

@interface RevSDK : NSObject

+ (void)startWithSDKKey:(NSString *)aSDKKey;

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
