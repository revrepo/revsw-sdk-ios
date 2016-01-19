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
