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

namespace rs
{
    NSString* localStorageDirectory();
    
    DataStorage::DataStorage()
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
    
    void DataStorage::saveConfiguration(const Configuration& aConfiguration)
    {
         NSDictionary* dictionary = NSDictionaryFromConfiguration(aConfiguration);
         saveObject(dictionary, kRSConfigurationStorageKey);
    }
    
    Configuration DataStorage::configuration() const
    {
        NSData* data                    = contentsOfFileWithName(kRSConfigurationStorageKey);
        NSDictionary* dictionary        = [NSPropertyListSerialization propertyListWithData:data
                                                                                    options:NSPropertyListImmutable
                                                                                     format:0
                                                                                      error:nil];
        rs::Configuration configuration = configurationFromNSDictionary(dictionary);
        return configuration;
    }
    
    void DataStorage::saveRequestData(const Data& aRequestData)
    {
        NSData* data                     = NSDataFromData(aRequestData);
        NSData* savedData                = contentsOfFileWithName(kRSRequestDataStorageKey);
        NSArray* requestDataArray        = [NSPropertyListSerialization propertyListWithData:savedData
                                                                                     options:NSPropertyListImmutable
                                                                                      format:0
                                                                                       error:nil];
        NSMutableArray* mutableDataArray = [NSMutableArray arrayWithArray:requestDataArray];
        
        [mutableDataArray addObject:data];
        saveObject(mutableDataArray, kRSRequestDataStorageKey);
    }
    
    std::vector<Data> DataStorage::loadRequestsData()
    {
        NSData* data                 = contentsOfFileWithName(kRSRequestDataStorageKey);
        NSArray* requestDataArray    = [NSPropertyListSerialization propertyListWithData:data
                                                                                 options:NSPropertyListImmutable
                                                                                  format:0
                                                                                   error:nil];
        std::vector<Data> dataVector = dataNSArrayToStdVector(requestDataArray);
        return dataVector;
    }
    
    void DataStorage::deleteRequestsData()
    {
        NSError* error = nil;
        
        BOOL success = deleteFile(kRSRequestDataStorageKey, &error);
        
        if (!success)
        {
            NSLog(@"Failed to remove requests data %@", error);
        }
    }
}
