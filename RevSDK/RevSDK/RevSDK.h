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
//! Project version number for RevSDK.
FOUNDATION_EXPORT double RevSDKVersionNumber;

//! Project version string for RevSDK.
FOUNDATION_EXPORT const unsigned char RevSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <RevSDK/PublicHeader.h>


@interface RevSDK : NSObject

+ (void)startWithSDKKey:(NSString *)aSDKKey;

@end
