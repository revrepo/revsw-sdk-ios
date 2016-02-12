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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#import "RSReachability.h"

#import "RSLocationService.h"
#import "NativeStatsHandler.h"
#import "RSStaticStatsProvider.h"
#include "Data.hpp"
#include "RSUtils.h"
#include "RSSystemInfo.h"
#include "RSIPUtils.h"
#include "Event.hpp"
#include "DataStorage.hpp"


#include "Model.hpp";

#define STRVALUE_OR_DEFAULT( x ) (x ? x : @"-")

static NSString* const kRSDeviceNameKey = @"kRSDeviceNameKey";
static NSString* const kRSOSVersionKey = @"kRSOSVersionKey";
//11.02.16 Perepelitsa: keys of report the name and version of “master” application
static NSString* const kRSJKeyAppName         = @"master_app_name";
static NSString* const kRSJKeyAppBundle       = @"master_app_bundle_id";
static NSString* const kRSJKeyAppVersion      = @"master_app_version";
static NSString* const kRSJKeyAppBuild        = @"master_app_build";  

static RSIPUtils* ipUtils = [RSIPUtils new];

namespace rs
{
    std::string NativeStatsHandler::appName()
    {
        NSBundle *bundle   = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        NSString *prodName = [info objectForKey:(NSString *)kCFBundleNameKey];
        
        return stdStringFromNSString(prodName);
    }
    
    std::string NativeStatsHandler::appVersion()
    {
        NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        return stdStringFromNSString(appVersionString);
    }
    
    NSString* deviceName()
    {
        struct utsname systemInfo;
        uname(&systemInfo);
        
        return [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
    }
    
    NSString* signalType()
    {
        RSReachability* reachability = [RSReachability rs_reachabilityForInternetConnection];
        return [reachability networkStatusString];
    }
    
    //11.02.16 Perepelitsa: Remove the “phone_type” logic from the SDK
    //  NSString* fullDeviceName()
    //  NSString* modelName()
    //  NSString* deviceModel()
    //  NSString* phoneType()
    //
    
    NSString* osVersion()
    {
        return [UIDevice currentDevice].systemVersion;
    }
    
    NSString* osName()
    {
        return @"iOS";
    }
    
    NSString* fullOSName()
    {
        return [NSString stringWithFormat:@"%@ %@", osName(), osVersion()];
    }
    
    NSString* batteryStateAsString()
    {
        NSString* state = @"full";
        
        switch ([[UIDevice currentDevice] batteryState])
        {
                
            case UIDeviceBatteryStateUnknown:
                state = @"unknown";
            case UIDeviceBatteryStateFull:
                state = @"full";
                break;
                
            case UIDeviceBatteryStateCharging:
                state = @"charging";
                break;
                
            case UIDeviceBatteryStateUnplugged:
                state = @"unplugged";
                break;
                
            default:
                break;
        }
        
        return state;
    }
    
    NSArray* logDataArray()
    {
        NSArray* events = (__bridge NSArray *)data_storage::loadEvents();
        data_storage::deleteEvents();
        return events;
    }
    
    //11.02.16 Perepelitsa: 
    NSDictionary* applicationInfo()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        
        statsDictionary[kRSJKeyAppName] = [[[NSBundle mainBundle] infoDictionary]  
                                                 objectForKey:(id)kCFBundleNameKey];

        statsDictionary[kRSJKeyAppBundle] = [[NSBundle mainBundle] bundleIdentifier];
        
        statsDictionary[kRSJKeyAppVersion] = [[[NSBundle mainBundle] infoDictionary]  
                                                objectForKey:(id)kCFBundleVersionKey];
        
        statsDictionary[kRSJKeyAppBuild] = [[[NSBundle mainBundle] infoDictionary] 
                                         objectForKey:@"CFBundleShortVersionString"]; 
        
        return statsDictionary;
    }
    //
    
    NSDictionary* wifiDataDict()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        
        statsDictionary[@"mac"] = @"_";
        statsDictionary[@"ssid"] = [RSSystemInfo ssid];
        statsDictionary[@"wifi_enc"] = @"_";
        statsDictionary[@"wifi_freq"] = @"_";
        statsDictionary[@"wifi_rssi"] = @"_";
        statsDictionary[@"wifi_rssibest"] = @"_";
        statsDictionary[@"wifi_sig"] = @"_";
        statsDictionary[@"wifi_speed"] = @"_";

        return statsDictionary;
    }
    
    NSDictionary* networkDataDict()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        
        statsDictionary[@"cellular_ip_external"] = STRVALUE_OR_DEFAULT(ipUtils.publicCellularIP);
        statsDictionary[@"cellular_ip_internal"] = STRVALUE_OR_DEFAULT(ipUtils.privateCellularIP);
        statsDictionary[@"dns1"] = STRVALUE_OR_DEFAULT(ipUtils.dns1);
        statsDictionary[@"dns2"] = STRVALUE_OR_DEFAULT(ipUtils.dns2);
        statsDictionary[@"ip_reassemblies"] = @"0";
        statsDictionary[@"ip_total_bytes_in"] = @"0";
        statsDictionary[@"ip_total_bytes_out"] = @"0";
        statsDictionary[@"ip_total_packets_in"] = @"0";
        statsDictionary[@"ip_total_packets_out"] = @"0";
        statsDictionary[@"rtt"] = @"0";
        statsDictionary[@"tcp_bytes_in"] = @"0";
        statsDictionary[@"tcp_bytes_out"] = @"0";
        statsDictionary[@"tcp_retransmits"] = @"0";
        statsDictionary[@"transport_protocol"] = @"_";
        statsDictionary[@"udp_bytes_in"] = @"0";
        statsDictionary[@"udp_bytes_out"] = @"0";
        statsDictionary[@"wifi_dhcp"] = @"_";
        statsDictionary[@"wifi_extip"] = STRVALUE_OR_DEFAULT(ipUtils.publicWifiIP);
        statsDictionary[@"wifi_gw"] = STRVALUE_OR_DEFAULT(ipUtils.gateway);
        statsDictionary[@"wifi_ip"] = STRVALUE_OR_DEFAULT(ipUtils.privateWiFiIP);
        statsDictionary[@"wifi_mask"] = STRVALUE_OR_DEFAULT(ipUtils.netmask);
        
        return statsDictionary;
    }
    
    NSDictionary* deviceDataDict()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
        
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        float batteryLevel = [[UIDevice currentDevice] batteryLevel];
        
        statsDictionary[@"batt_cap"] = [NSNumber numberWithFloat:batteryLevel*100];
        statsDictionary[@"batt_status"] = batteryStateAsString();
        statsDictionary[@"batt_tech"] = @"Li-Ion";
        statsDictionary[@"batt_temp"] = @"_";
        statsDictionary[@"batt_volt"] = @"_";
        statsDictionary[@"brand"] = @"_";
        statsDictionary[@"cpu"] = @"_";
        statsDictionary[@"cpu_cores"] = @"0";
        statsDictionary[@"cpu_freq"] = @"_";
        statsDictionary[@"cpu_number"] = @"1.0";
        statsDictionary[@"cpu_sub"] = @"0";
        //11.02.16 Perepelitsa: Remove the “phone_type” logic from the SDK
        //statsDictionary[@"device"] = deviceModel();
        statsDictionary[@"device"] = deviceName();
        statsDictionary[@"height"] = [NSString stringWithFormat:@"%f", screenHeight];
        statsDictionary[@"iccid"] = @"_";
        statsDictionary[@"imei"] = @"_";
        statsDictionary[@"imsi"] = @"_";
        statsDictionary[@"manufacture"] = @"Apple";
        statsDictionary[@"meis"] = @"_";
        statsDictionary[@"os"] = fullOSName();
        statsDictionary[@"os_name"] = osName();
        statsDictionary[@"os_version"] = osVersion();
        statsDictionary[@"phone_number"] = @"1.0";
        statsDictionary[@"radio_serial"] = @"_";
        statsDictionary[@"serial_number"] = @"_";
        statsDictionary[@"uuid"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        statsDictionary[@"width"] = [NSString stringWithFormat:@"%f", screenWidth];
        
        return statsDictionary;
    }
    
    NSDictionary* carrierDataDict()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        
        statsDictionary[@"country_code"] = STRVALUE_OR_DEFAULT([RSSystemInfo countryCode]);
        statsDictionary[@"device_id"] = @"_";
        statsDictionary[@"mcc"] =  STRVALUE_OR_DEFAULT([RSSystemInfo mobileCountryCode]);
        statsDictionary[@"mnc"] = STRVALUE_OR_DEFAULT([RSSystemInfo mobileNetworkCode]);
        statsDictionary[@"net_operator"] = STRVALUE_OR_DEFAULT([RSSystemInfo carrierName]);
        statsDictionary[@"network_type"] = STRVALUE_OR_DEFAULT([RSSystemInfo radioAccessTechnology]);
        //11.02.16 Perepelitsa: Remove the “phone_type” logic from the SDK
        //statsDictionary[@"phone_type"] = phoneType();
        //
        statsDictionary[@"rssi"] = @"_";
        statsDictionary[@"rssi_avg"] = @"_";
        statsDictionary[@"rssi_best"] = @"_";
        statsDictionary[@"signal_type"] = signalType();
        statsDictionary[@"sim_operator"] = STRVALUE_OR_DEFAULT([RSSystemInfo carrierName]);
        statsDictionary[@"tower_cell_id_l"] = @"_";
        statsDictionary[@"tower_cell_id_s"] = @"_";
        
        return statsDictionary;
    }
    
    NSDictionary* statsDataDict()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        statsDictionary[kRSDeviceNameKey]    = deviceName();
        statsDictionary[kRSOSVersionKey]     = osVersion();
        
        return statsDictionary;
    }
    
    NSDictionary* locationDataDict()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        RSLocationService* service = [RSLocationService sharedService];
        
        float speed = service.lastLocation.location.speed;
        float direction = service.lastLocation.direction;
        
        statsDictionary[@"direction"] = [NSNumber numberWithFloat:direction];
        statsDictionary[@"latitude"]  = [NSNumber numberWithDouble:service.lastLocation.latitude];
        statsDictionary[@"longitude"] = [NSNumber numberWithDouble:service.lastLocation.longitude];
        statsDictionary[@"speed"]     = [NSNumber numberWithFloat:speed];
        
        return statsDictionary;
    }
    
    Data NativeStatsHandler::logData()
    {
        NSArray* logArray = logDataArray();
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:logArray
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
        Data rsData = dataFromNSData(nsData);
        
        return rsData;
    }
    
    Data NativeStatsHandler::wifiData()
    {
        NSDictionary* statsDictionary = wifiDataDict();
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:statsDictionary
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
        Data rsData = dataFromNSData(nsData);
        
        return rsData;
    }
    
    Data NativeStatsHandler::networkData()
    {
        NSDictionary* statsDictionary = networkDataDict();
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:statsDictionary
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
        Data rsData = dataFromNSData(nsData);
        
        return rsData;
    }
    
    Data NativeStatsHandler::deviceData()
    {
        NSDictionary* statsDictionary = deviceDataDict();
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:statsDictionary
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
        Data rsData = dataFromNSData(nsData);
        
        return rsData;
    }
    
    Data NativeStatsHandler::carrierData()
    {
        NSDictionary* statsDictionary = carrierDataDict();
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:statsDictionary
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
        Data rsData = dataFromNSData(nsData);
        
        return rsData;
    }
    
    Data NativeStatsHandler::statsData()
    {
        NSDictionary* statsDictionary = statsDataDict();
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:statsDictionary
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
        Data rsData = dataFromNSData(nsData);
        
        return rsData;
    }
    
    Data NativeStatsHandler::locationData()
    {
        NSDictionary* statsDictionary = locationDataDict();
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:statsDictionary
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
        Data rsData = dataFromNSData(nsData);
        
        return rsData;
    }
    
    Data NativeStatsHandler::allData(const Data& aRequestsData, const std::map<std::string, std::string>& aParams)
    {
        NSData* rd = [NSData dataWithBytes:aRequestsData.bytes() length:aRequestsData.length()];
        id requestsDataSrc = [NSJSONSerialization JSONObjectWithData:rd
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        
        NSMutableArray* requestsData = [NSMutableArray array];
        
        if ([requestsDataSrc isKindOfClass:[NSArray class]])
        {
            for (NSString* str in requestsDataSrc)
            {
                if ([str isKindOfClass:[NSString class]])
                {
                    NSData* objData = [str dataUsingEncoding:NSUTF8StringEncoding];
                    id obj = [NSJSONSerialization JSONObjectWithData:objData
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
                    if (obj != nil)
                        [requestsData addObject:obj];
                }
            }
        }
        
        NSMutableDictionary* sd = [NSMutableDictionary dictionary];
        
        if (requestsData != nil)
            sd[@"requests"]  = requestsData;
        sd[@"network"] = networkDataDict();
        sd[@"device"] = deviceDataDict();
        sd[@"carrier"] = carrierDataDict();
        sd[@"wifi"] = wifiDataDict();
        sd[@"location"] = locationDataDict();
        sd[@"log_events"] = logDataArray();
        sd[@"applicationInfo"] = applicationInfo();
        //12.02.16 Perepelitsa: move a_b_mode flag into json root        
        sd[@"a_b_mode"] =  @(Model::instance()->abTestingMode()); 
        //
        for (auto& i : aParams)
        {
            NSString* key = [NSString stringWithUTF8String:i.first.c_str()];
            NSString* value = [NSString stringWithUTF8String:i.second.c_str()];
            if (key != nil && value != nil)
                sd[key] = value;
        }
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:sd
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:nil];
        
        return dataFromNSData(nsData);
    }
    
    void NativeStatsHandler::addEvent(const Event& aEvent)
    {
        data_storage::addEvent(aEvent);
    }
    
    void NativeStatsHandler::startMonitoring()
    {
        [ipUtils startMonitoring];
    }
    
    void NativeStatsHandler::stopMonitoring()
    {
        [ipUtils stopMonitoring];
    }
}