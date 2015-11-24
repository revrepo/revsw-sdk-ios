//
//  RSNativeDataStorage.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSNativeDataStorage.h"
#import "Data.hpp"
#import "RSUtils.h"
#import "Configuration.hpp"

@interface RSNativeDataStorage ()

- (void)saveObject:(id)aObject forKey:(NSString *)aKey;
- (id)objectForKey:(NSString *)aKey;

@end

@implementation RSNativeDataStorage

- (void)saveConfiguration:(rs::Configuration)aConfiguration
{
    NSDictionary* dictionary = rs::NSDictionaryFromConfiguration(aConfiguration);
    [self saveObject:dictionary forKey:@"configuration_key"];
}

- (rs::Configuration)configuration
{
    NSMutableDictionary* dictionary = [self objectForKey:@"configuration_key"];
    rs::Configuration configuration = rs::configurationFromNSDictionary(dictionary);
    return configuration;
}

- (void)saveObject:(id)aObject forKey:(NSString *)aKey
{
    [[NSUserDefaults standardUserDefaults] setObject:aObject forKey:aKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)objectForKey:(NSString *)aKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
}

@end
