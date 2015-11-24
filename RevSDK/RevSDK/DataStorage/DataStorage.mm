//
//  DataStorage.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "DataStorage.hpp"
#include "Configuration.hpp"
#include "RSUtils.h"
#import "RSNativeDataStorage.h"

namespace rs
{
    DataStorage::DataStorage()
    {
        nativeDataStorage = (void *)CFBridgingRetain([RSNativeDataStorage new]);
    }
    
    DataStorage::~DataStorage()
    {
        CFBridgingRelease(nativeDataStorage);
    }

    void DataStorage::saveConfiguration(const Configuration& aConfiguration)
    {
        [(__bridge RSNativeDataStorage *)nativeDataStorage saveConfiguration:aConfiguration];
    }
    
    Configuration DataStorage::configuration()const
    {
        return [(__bridge RSNativeDataStorage *)nativeDataStorage configuration];
    }
}