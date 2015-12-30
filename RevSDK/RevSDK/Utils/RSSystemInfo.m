//
//  RSSystemInfo.m
//  RevSDK
//
//  Created by Andrey Chernukha on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSSystemInfo.h"

@import CoreTelephony;
@import SystemConfiguration.CaptiveNetwork;
@import UIKit;

@implementation RSSystemInfo

+ (CTCarrier*) currentCarrier
{
    static CTCarrier* carrier = nil;
    
    if (!carrier)
    {
        CTTelephonyNetworkInfo* network_Info = [CTTelephonyNetworkInfo new];
        carrier                              = network_Info.subscriberCellularProvider;
    }
    
    return carrier;
}

+ (NSString*) countryCode
{
    return [self currentCarrier].isoCountryCode;
}

+ (NSString*) mobileCountryCode
{
    return [self currentCarrier].mobileCountryCode;
}

+ (NSString*) mobileNetworkCode
{
    return [self currentCarrier].mobileCountryCode;
}

+ (NSString*) carrierName
{
    CTCarrier* carrier = [self currentCarrier ];
    NSString* carrierName = carrier.carrierName;
    
    if (!carrierName || [carrierName isEqualToString:@"Carrier"])
    {
        return @"_";
    }
    
    return carrierName;
}

+ (NSString*) radioAccessTechnology
{
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    NSString* networkType                 = telephonyInfo.currentRadioAccessTechnology;
    
    if (!networkType)
    {
        return @"_";
    }
    
    return [networkType stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology" withString:@""];
}

+ (NSString*) ssid
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    
    NSDictionary *SSIDInfo;
    
    for (NSString *interfaceName in interfaceNames)
    {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        
        if (isNotEmpty) {
            break;
        }
    }
    
    NSString* retString = [NSString stringWithFormat:@"%@ (%@)", SSIDInfo[@"SSID"], SSIDInfo[@"BSSID"]];
    
    return retString;
}

@end