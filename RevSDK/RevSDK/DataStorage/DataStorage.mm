//
//  RSNativeDataStorage.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataStorage.hpp"
#import "Data.hpp"
#import "RSUtils.h"
#import "Configuration.hpp"
#import "Event.hpp"

namespace rs
{
    
    NSString* localStorageDirectory();
    
    void data_storage::initDataStorage()
    {
        NSString* storageDirectory = localStorageDirectory();
        BOOL exists                = [[NSFileManager defaultManager] fileExistsAtPath:storageDirectory];
        
        if (!exists)
        {
            NSError* error = nil;
            
            BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:storageDirectory
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:&error];
            
            if (!success)
            {
                NSLog(@"Failed to create storage directory %@", error);
            }
        }
    }
    
    NSString* documentsDirectory()
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = paths.firstObject;
        return basePath;
    }
    
    NSString* localStorageDirectory()
    {
        NSString* docsDirectory    = documentsDirectory();
        NSString* storageDirectory = [docsDirectory stringByAppendingString:@"/sdk_storage"];
        
        return storageDirectory;
    }
    
    NSString* fullPathForFileName(NSString* aFileName)
    {
        NSString* storageDirectory = localStorageDirectory();
        NSString* fullPath         = [storageDirectory stringByAppendingPathComponent:aFileName];
        
        return fullPath;
    }
    
    BOOL canWriteToPath(NSString* aPath)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:aPath])
        {
            NSError* error = nil;
            
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:aPath
                                                                      error:&error];
            
            if (!success)
            {
                NSLog(@"Failed to remove item %@", error);
            }
            
            return success;
        }

        return YES;
    }
    
    void saveObject(id object, NSString* aFileName)
    {
        NSString* fullPath = fullPathForFileName(aFileName);
        
        if (canWriteToPath(fullPath))
        {
             if ([object respondsToSelector:@selector(writeToFile:atomically:)])
             {
                  [object writeToFile:fullPath atomically:YES];
             }
             else
             {
                 NSLog(@"Object of unknown type %@", [object class]);
             }
        }
    }
    
    NSData* contentsOfFileWithName(NSString* aFileName)
    {
         NSString* fullPath = fullPathForFileName(aFileName);
        
         return [[NSFileManager defaultManager] contentsAtPath:fullPath];
    }
    
    BOOL deleteFile(NSString * aFileName, NSError** aError)
    {
         NSString* fullPath = fullPathForFileName(aFileName);
         NSError* error     = nil;
        
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:fullPath
                                                                  error:&error];
        
        if (!success)
        {
            *aError = error;
        }
        
        return success;
    }
    
    void data_storage::saveConfiguration(const Configuration& aConfiguration)
    {
         NSDictionary* dictionary = NSDictionaryFromConfiguration(aConfiguration);
         saveObject(dictionary, kRSConfigurationStorageKey);
    }
    
    Configuration data_storage::configuration()
    {
        NSData* data             = contentsOfFileWithName(kRSConfigurationStorageKey);
        NSDictionary* dictionary = data ? [NSPropertyListSerialization propertyListWithData:data
                                                                                    options:NSPropertyListImmutable
                                                                                     format:0
                                                                                      error:nil] : @{};
        rs::Configuration configuration = configurationFromNSDictionary(dictionary);
        return configuration;
    }
    
    void data_storage::saveRequestData(const Data& aRequestData)
    {
        NSData* data                     = NSDataFromData(aRequestData);
        NSData* savedData                = contentsOfFileWithName(kRSRequestDataStorageKey);
        NSArray* requestDataArray        = savedData ? [NSPropertyListSerialization propertyListWithData:savedData
                                                                                     options:NSPropertyListImmutable
                                                                                      format:0
                                                                                                   error:nil] : @[];
        NSMutableArray* mutableDataArray = [NSMutableArray arrayWithArray:requestDataArray];
        
        [mutableDataArray addObject:data];
        saveObject(mutableDataArray, kRSRequestDataStorageKey);
    }
    
    void data_storage::saveRequestDataVec(const std::vector<Data>& aRequestDataVec)
    {
        NSData* savedData                = contentsOfFileWithName(kRSRequestDataStorageKey);
        NSArray* requestDataArray        = savedData ? [NSPropertyListSerialization propertyListWithData:savedData
                                                                                                 options:NSPropertyListImmutable
                                                                                                  format:0
                                                                                                   error:nil] : @[];
        NSMutableArray* mutableDataArray = [NSMutableArray arrayWithArray:requestDataArray];
        
        for (auto it: aRequestDataVec)
        {
            NSData* data  = NSDataFromData(it);
            [mutableDataArray addObject:data];
        }
        
        saveObject(mutableDataArray, kRSRequestDataStorageKey);
    }
    
    void data_storage::saveAvailableProtocols(std::vector<std::string> aVec)
    {
        NSData* savedData                = contentsOfFileWithName(kRSRequestDataStorageKey);
        NSArray* requestDataArray        = savedData ? [NSPropertyListSerialization propertyListWithData:savedData
                                                                                                 options:NSPropertyListImmutable
                                                                                                  format:0
                                                                                                   error:nil] : @[];
        NSMutableArray* mutableDataArray = [NSMutableArray arrayWithArray:requestDataArray];
        
        for (auto it: aVec)
        {
            [mutableDataArray addObject:NSStringFromStdString(it)];
        }
        
        saveObject(mutableDataArray, kRSLastMileDataStorageKey);
    }
    
    std::vector<std::string> data_storage::restoreAvailableProtocols()
    {
        std::vector<std::string> vec;
        
        NSData* data = contentsOfFileWithName(kRSLastMileDataStorageKey);
        
        if (!data)
        {
            return vec;
        }
        
        NSArray* requestDataArray    = [NSPropertyListSerialization propertyListWithData:data
                                                                                 options:NSPropertyListImmutable
                                                                                  format:0
                                                                                   error:nil];
  
        for (id object in requestDataArray)
        {
            vec.push_back(stdStringFromNSString(object));
        }
        
        return vec;
    }
    
    void data_storage::saveIntForKey(const std::string& aKey, int64_t aVal)
    {
        NSString* nsKey = NSStringFromStdString(aKey);
        
        [[NSUserDefaults standardUserDefaults] setInteger:aVal forKey:nsKey];
    }
    
    int64_t data_storage::getIntForKey(const std::string& aKey)
    {
        NSString* nsKey = NSStringFromStdString(aKey);
        
        int64_t val = [[NSUserDefaults standardUserDefaults] integerForKey:nsKey];
        
        return val;
    }
    
    std::vector<Data> data_storage::loadRequestsData()
    {
        NSData* data = contentsOfFileWithName(kRSRequestDataStorageKey);
        
        if (!data)
        {
            return std::vector<Data>();
        }
        
        NSArray* requestDataArray    = [NSPropertyListSerialization propertyListWithData:data
                                                                                 options:NSPropertyListImmutable
                                                                                  format:0
                                                                                   error:nil];
        std::vector<Data> dataVector = dataNSArrayToStdVector(requestDataArray);
        return dataVector;
        /*
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        
        dict[@"conn_id"] = @"0";
        dict[@"cont_encoding"] = @"_";
        dict[@"con_type"] = @"_";
        dict[@"end_ts"] = @"0";
        dict[@"first_byte_ts"] = @"0";
        dict[@"keepalive_status"] = @"0";
        dict[@"local_cache_status"] = @"_";
        dict[@"method"] = @"_";
        dict[@"network"] = @"_";
        dict[@"protocol"] = @"_";
        dict[@"received_bytes"] = @"0";
        dict[@"sent_bytes"] = @"0";
        dict[@"start_ts"] = @"0";
        dict[@"success_status"] = @"0";
        dict[@"status_code"] = @"0";
        dict[@"transport_protocol"] = @"_";
        dict[@"url:"] = @"request";
        
        NSArray* array = @[dict];
        
        NSData* data = [NSJSONSerialization dataWithJSONObject:array
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        
        Data _data = dataFromNSData(data);
        
        std::vector<Data> vd = {_data};
        
        return vd;*/
    }
    
    void data_storage::deleteRequestsData()
    {
        NSError* error = nil;
        
        BOOL success = deleteFile(kRSRequestDataStorageKey, &error);
        
//        if (!success)
//        {
//            NSLog(@"Failed to remove requests data %@", error);
//        }
    }
    
    void data_storage::addEvent(const Event& aEvent)
    {
        NSString* path                     = fullPathForFileName(kRSEventsDataStorageKey);
        NSArray* savedEvents               = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray* mutableSavedEvents = savedEvents ? [NSMutableArray arrayWithArray:savedEvents] : [NSMutableArray array];
        
        NSString* severity  = NSStringFromStdString(aEvent.severity);
        NSString* code      = [NSString stringWithFormat:@"%d", aEvent.code];
        NSString* message   = NSStringFromStdString(aEvent.message);
        NSString* interval  = [NSString stringWithFormat:@"%.f", aEvent.interval];
        NSString* timestamp = [NSString stringWithFormat:@"%.Lf", aEvent.timestamp];
        
        NSMutableDictionary* eventDictionary = [NSMutableDictionary dictionaryWithObjects:@[severity, code, message, interval, timestamp]
                                                                                  forKeys:@[@"log_severity", @"log_event_code", @"log_message", @"log_interval", @"timestamp"]];
        
        [mutableSavedEvents addObject:eventDictionary];
        
        saveObject(mutableSavedEvents, kRSEventsDataStorageKey);
    }
    
    void* data_storage::loadEvents()
    {
        NSString* path       = fullPathForFileName(kRSEventsDataStorageKey);
        NSArray* savedEvents = [NSArray arrayWithContentsOfFile:path];
        
        if (!savedEvents)
        {
            savedEvents = @[];
        }
        
        return (__bridge void *)savedEvents;
    }
    
    void data_storage::deleteEvents()
    {
        NSError* error = nil;
        
        deleteFile(kRSEventsDataStorageKey, &error);
    }
}
