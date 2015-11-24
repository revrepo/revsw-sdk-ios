//
//  DataStorage.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "DataStorage.hpp"
#include "Configuration.hpp"
#import "NativeDataStorage.h"

namespace rs
{
    DataStorage::DataStorage()
    {
        nativeDataStorage = new NativeDataStorage();
    }
    
    DataStorage::~DataStorage()
    {
        delete nativeDataStorage;
    }

    void DataStorage::saveConfiguration(const Configuration& aConfiguration)
    {
        nativeDataStorage->saveConfiguration(aConfiguration);
    }
    
    Configuration DataStorage::configuration()const
    {
        return nativeDataStorage->configuration();
    }
}