//
//  NativeStatsHandler.m
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#import "RSLocationService.h"

#import "NativeStatsHandler.h"
#import "RSStaticStatsProvider.h"
#include "Data.hpp"
#include "RSUtils.h"


static NSString* const kRSDeviceNameKey = @"kRSDeviceNameKey";
static NSString* const kRSOSVersionKey = @"kRSOSVersionKey";

namespace rs
{
    std::string NativeStatsHandler::appName()
    {
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
        
        return stdStringFromNSString(prodName);
    }
    
    NSString* deviceName()
    {
        struct utsname systemInfo;
        uname(&systemInfo);
        
        return [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
    }
    
    NSString* osVersion()
    {
        return [UIDevice currentDevice].systemVersion;
    }
    
    NSString* batteryStateAsString()
    {
        NSString* state = @"full";
        
        switch ([[UIDevice currentDevice] batteryState])
        {
            case UIDeviceBatteryStateUnknown:
                state = @"unknown";
                break;
                
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
    
    
    NSDictionary* logDataDict()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        
        statsDictionary[@"log_severity"] = @"_";
        statsDictionary[@"log_event_code"] = @"0";
        statsDictionary[@"log_message"] = @"_";
        statsDictionary[@"log_interval"] = @"1.0";
        
        return statsDictionary;
    }
    
    NSDictionary* wifiDataDict()
    {
        NSMutableDictionary* statsDictionary = [NSMutableDictionary dictionary];
        
        statsDictionary[@"mac"] = @"_";
        statsDictionary[@"ssid"] = @"_";
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
        
        statsDictionary[@"cellular_ip_external"] = @"8.8.8.8";
        statsDictionary[@"cellular_ip_internal"] = @"_";
        statsDictionary[@"dns1"] = @"_";
        statsDictionary[@"dns2"] = @"_";
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
        statsDictionary[@"wifi_extip"] = @"_";
        statsDictionary[@"wifi_qw"] = @"_";
        statsDictionary[@"wifi_ip"] = @"1.0";
        statsDictionary[@"wifi_mask"] = @"_";
        
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
        statsDictionary[@"device"] = deviceName();
        statsDictionary[@"hight"] = [NSString stringWithFormat:@"%f", screenHeight];
        statsDictionary[@"iccid"] = @"_";
        statsDictionary[@"imei"] = @"_";
        statsDictionary[@"imsi"] = @"_";
        statsDictionary[@"manufacture"] = @"Apple";
        statsDictionary[@"meis"] = @"_";
        statsDictionary[@"os"] = osVersion();
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
        
        statsDictionary[@"country_code"] = @"_";
        statsDictionary[@"device_id"] = @"_";
        statsDictionary[@"mcc"] = @"_";
        statsDictionary[@"mnc"] = @"_";
        statsDictionary[@"net_operator"] = @"_";
        statsDictionary[@"network_type"] = @"_";
        statsDictionary[@"phone_type"] = @"_";
        statsDictionary[@"rssi"] = @"1.0";
        statsDictionary[@"rssi_avg"] = @"1.0";
        statsDictionary[@"rssi_best"] = @"1.0";
        statsDictionary[@"signal_type"] = @"_";
        statsDictionary[@"sim_operator"] = @"_";
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
        NSDictionary* statsDictionary = logDataDict();
        
        NSData* nsData = [NSJSONSerialization dataWithJSONObject:statsDictionary
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
        sd[@"log_events"] = logDataDict();
        
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
}