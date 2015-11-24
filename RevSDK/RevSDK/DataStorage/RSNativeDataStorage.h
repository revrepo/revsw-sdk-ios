//
//  RSNativeDataStorage.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <string.h>
#include <iostream>

namespace rs
{
    struct Configuration;
}

@interface RSNativeDataStorage : NSObject

- (void)saveConfiguration:(rs::Configuration)aConfiguration;
- (rs::Configuration)configuration;

@end
