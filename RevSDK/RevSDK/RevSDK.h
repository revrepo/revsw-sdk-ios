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

typedef enum
{
    kRSOperationModeOff,
    kRSOperationModeTransport,
    kRSOperationModeReport,
    kRSOperationModeTransportAndReport
}RSOperationMode;

@interface RevSDK : NSObject

+ (void)startWithSDKKey:(NSString *)aSDKKey;
+ (void)setOperationMode:(RSOperationMode)aOperationMode;
+ (RSOperationMode)operationMode;
+ (void)setWhiteListOption:(BOOL)aOn;
+ (void)setTestPassOption:(BOOL)aOn;

@end
