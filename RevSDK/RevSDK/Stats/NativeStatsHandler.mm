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

#define STRVALUE_OR_DEFAULT( x ) (x ? x : @"-")

static NSString* const kRSDeviceNameKey = @"kRSDeviceNameKey";
static NSString* const kRSOSVersionKey = @"kRSOSVersionKey";

static RSIPUtils* ipUtils = [RSIPUtils new];

namespace rs
{
    std::string NativeStatsHandler::appName()
    {
        NSBundle *bundle   = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
        
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
    
    NSString* fullDeviceName()
    {
        NSString* device = deviceName();
        
        NSDictionary *commonNamesDictionary =
        @{
          @"i386":     @"iPhone Simulator",
          @"x86_64":   @"iPad Simulator",
          
          @"AppleTV2,1" : @"Apple TV 2G",
          @"AppleTV3,1" : @"Apple TV 3G",
          @"AppleTV3,2" : @"Apple TV 3G",
          @"AppleTV5,3" : @"Apple TV 4G",
          
          @"Watch1,1" : @"Apple Watch",
          @"Watch1,2" : @"Apple Watch",
          
          @"iPhone1,1":    @"iPhone",
          @"iPhone1,2":    @"iPhone 3G",
          @"iPhone2,1":    @"iPhone 3GS",
          @"iPhone3,1":    @"iPhone 4",
          @"iPhone3,2":    @"iPhone 4(Rev A)",
          @"iPhone3,3":    @"iPhone 4(CDMA)",
          @"iPhone4,1":    @"iPhone 4S",
          @"iPhone5,1":    @"iPhone 5(GSM)",
          @"iPhone5,2":    @"iPhone 5(GSM+CDMA)",
          @"iPhone5,3":    @"iPhone 5c(GSM)",
          @"iPhone5,4":    @"iPhone 5c(GSM+CDMA)",
          @"iPhone6,1":    @"iPhone 5s(GSM)",
          @"iPhone6,2":    @"iPhone 5s(GSM+CDMA)",
          
          @"iPhone7,1":    @"iPhone 6+ (GSM+CDMA)",
          @"iPhone7,2":    @"iPhone 6 (GSM+CDMA)",
          
          @"iPhone8,1":    @"iPhone 6S (GSM+CDMA)",
          @"iPhone8,2":    @"iPhone 6S+ (GSM+CDMA)",
          
          @"iPad1,1":  @"iPad",
          @"iPad2,1":  @"iPad 2(WiFi)",
          @"iPad2,2":  @"iPad 2(GSM)",
          @"iPad2,3":  @"iPad 2(CDMA)",
          @"iPad2,4":  @"iPad 2(WiFi Rev A)",
          @"iPad2,5":  @"iPad Mini 1G (WiFi)",
          @"iPad2,6":  @"iPad Mini 1G (GSM)",
          @"iPad2,7":  @"iPad Mini 1G (GSM+CDMA)",
          @"iPad3,1":  @"iPad 3(WiFi)",
          @"iPad3,2":  @"iPad 3(GSM+CDMA)",
          @"iPad3,3":  @"iPad 3(GSM)",
          @"iPad3,4":  @"iPad 4(WiFi)",
          @"iPad3,5":  @"iPad 4(GSM)",
          @"iPad3,6":  @"iPad 4(GSM+CDMA)",
          
          @"iPad4,1":  @"iPad Air(WiFi)",
          @"iPad4,2":  @"iPad Air(GSM)",
          @"iPad4,3":  @"iPad Air(GSM+CDMA)",
          
          @"iPad5,3":  @"iPad Air 2 (WiFi)",
          @"iPad5,4":  @"iPad Air 2 (GSM+CDMA)",
          
          @"iPad4,4":  @"iPad Mini 2G (WiFi)",
          @"iPad4,5":  @"iPad Mini 2G (GSM)",
          @"iPad4,6":  @"iPad Mini 2G (GSM+CDMA)",
          
          @"iPad4,7":  @"iPad Mini 3G (WiFi)",
          @"iPad4,8":  @"iPad Mini 3G (GSM)",
          @"iPad4,9":  @"iPad Mini 3G (GSM+CDMA)",
          
          @"iPad5,1" : @"iPad Mini 4 (WiFi)",
          @"iPad5,2" : @"iPad Mini 4 (GSM)",
          
          @"iPad6,7" : @"iPad Pro",
          @"iPad6,8" : @"iPad Pro",
          
          @"iPod1,1":  @"iPod 1st Gen",
          @"iPod2,1":  @"iPod 2nd Gen",
          @"iPod3,1":  @"iPod 3rd Gen",
          @"iPod4,1":  @"iPod 4th Gen",
          @"iPod5,1":  @"iPod 5th Gen",
          @"iPod7,1":  @"iPod 6th Gen",
          };
        
        NSString *deviceName = commonNamesDictionary[device];
        
        if (deviceName == nil) {
            deviceName = device;
        }
        
        return deviceName;
    }
    
    NSString* modelName()
    {
         NSString* device = deviceName();
        
        NSDictionary* modelDict = @{
                                    @"i386":     @"iPhone Simulator",
                                    @"x86_64":   @"iPad Simulator",
                                    
                                    
                                    @"AppleTV2,1" : @"A1378",
                                    @"AppleTV3,1" : @"A1427",
                                    @"AppleTV3,2" : @"A1469",
                                    @"AppleTV5,3" : @"A1625",
                                    
                                    @"Watch1,1" : @"A1553",
                                    @"Watch1,2" : @"A1554/A1638",
                                    
                                    @"iPhone1,1":    @"A1203",
                                    @"iPhone1,2":    @"A1241/A1324",
                                    @"iPhone2,1":    @"A1303/A1325",
                                    @"iPhone3,1":    @"A1332",
                                    @"iPhone3,2":    @"A1332",
                                    @"iPhone3,3":    @"A1349",
                                    @"iPhone4,1":    @"A1387/A1431",
                                    @"iPhone5,1":    @"A1428",
                                    @"iPhone5,2":    @"A1429/A1442",
                                    @"iPhone5,3":    @"A1456/A1532",
                                    @"iPhone5,4":    @"A1507/A1516/A1526/A1529",
                                    @"iPhone6,1":    @"A1453/A1533",
                                    @"iPhone6,2":    @"A1457/A1518/A1528/A1530",
                                    
                                    @"iPhone7,1":    @"A1522/A1524",
                                    @"iPhone7,2":    @"A1549/A1586",
                                    
                                    @"iPhone8,1":    @"A1633/A1688/A1691/A1700",
                                    @"iPhone8,2":    @"A1634/A1687/A1690/A1699",
                                    
                                    @"iPad1,1":  @"A1219/A1337",
                                    @"iPad2,1":  @"A1395",
                                    @"iPad2,2":  @"A1396",
                                    @"iPad2,3":  @"A1397",
                                    @"iPad2,4":  @"A1395",
                                    @"iPad2,5":  @"A1432",
                                    @"iPad2,6":  @"A1454",
                                    @"iPad2,7":  @"A1455",
                                    @"iPad3,1":  @"A1416",
                                    @"iPad3,2":  @"A1403",
                                    @"iPad3,3":  @"A1430",
                                    @"iPad3,4":  @"A1458",
                                    @"iPad3,5":  @"A1459",
                                    @"iPad3,6":  @"A1460",
                                    
                                    @"iPad4,1":  @"A1474",
                                    @"iPad4,2":  @"A1475",
                                    @"iPad4,3":  @"A1476",
                                    
                                    @"iPad5,1":  @"A1538",
                                    @"iPad5,2":  @"A1550",
                                    @"iPad5,3":  @"A1566",
                                    @"iPad5,4":  @"A1567",
                                    
                                    @"iPad4,4":  @"A1489",
                                    @"iPad4,5":  @"A1490",
                                    @"iPad4,6":  @"A1491",
                                    
                                    @"iPad4,7":  @"A1599",
                                    @"iPad4,8":  @"A1600",
                                    @"iPad4,9":  @"A1601",
                                    
                                    @"iPad6,7" : @"A1584",
                                    @"iPad6,8" : @"A1652",
                                    
                                    @"iPod1,1":  @"A1213",
                                    @"iPod2,1":  @"A1288/A1319",
                                    @"iPod3,1":  @"A1318",
                                    @"iPod4,1":  @"A1367",
                                    @"iPod5,1":  @"A1421",
                                    @"iPod7,1":  @"A1574",
                               };
        
        NSString* model = modelDict[device];
        
        if (!model)
        {
            model = device;
        }
        
        return model;
    }
    
    NSString* deviceModel()
    {
        NSString* device = deviceName();
        NSString* model  = modelName();
        
        return [NSString stringWithFormat:@"%@ %@", device, model];
    }
    
    NSString* phoneType()
    {
        NSString* fullName    = fullDeviceName();
        NSString* GSMPlusCDMA = @"GSM+CDMA";
        NSString* GSM         = @"GSM";
        NSString* CDMA        = @"CDMA";
        NSString* wifi        = @"WiFi";
        
        for (NSString* string in @[GSMPlusCDMA, GSM, CDMA, wifi])
        {
            if ([fullName rangeOfString:string].location != NSNotFound)
            {
                return string;
            }
        }
        
        return @"_";
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
        statsDictionary[@"device"] = deviceModel();
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
        
        statsDictionary[@"country_code"] = STRVALUE_OR_DEFAULT([RSSystemInfo countryCode]);
        statsDictionary[@"device_id"] = @"_";
        statsDictionary[@"mcc"] =  STRVALUE_OR_DEFAULT([RSSystemInfo mobileCountryCode]);
        statsDictionary[@"mnc"] = STRVALUE_OR_DEFAULT([RSSystemInfo mobileNetworkCode]);
        statsDictionary[@"net_operator"] = STRVALUE_OR_DEFAULT([RSSystemInfo carrierName]);
        statsDictionary[@"network_type"] = STRVALUE_OR_DEFAULT([RSSystemInfo radioAccessTechnology]);
        statsDictionary[@"phone_type"] = phoneType();
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