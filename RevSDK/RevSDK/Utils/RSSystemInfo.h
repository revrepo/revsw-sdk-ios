//
//  RSSystemInfo.h
//  RevSDK
//
//  Created by Andrey Chernukha on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSystemInfo : NSObject

+ (NSString*) countryCode;
+ (NSString*) mobileCountryCode;
+ (NSString*) mobileNetworkCode;
+ (NSString*) carrierName;
+ (NSString*) radioAccessTechnology;
+ (NSString*) ssid;

@end