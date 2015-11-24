//
//  RSNativeDataStorage.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NativeDataStorage.h"
#import "Data.hpp"
#import "RSUtils.h"
#import "Configuration.hpp"

namespace rs
{
    void saveObjectForKey(id aObject, NSString* aKey)
    {
        [[NSUserDefaults standardUserDefaults] setObject:aObject forKey:aKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    id objectForKey(NSString* aKey)
    {
         return [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
    }
    
    void NativeDataStorage::saveConfiguration(Configuration aConfiguration)
    {
         NSDictionary* dictionary = NSDictionaryFromConfiguration(aConfiguration);
         saveObjectForKey(dictionary, kRSConfigurationStorageKey);
    }
    
    Configuration NativeDataStorage::configuration() const
    {
        NSMutableDictionary* dictionary = objectForKey(kRSConfigurationStorageKey);
        rs::Configuration configuration = configurationFromNSDictionary(dictionary);
        return configuration;
    }
}
