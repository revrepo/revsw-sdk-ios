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