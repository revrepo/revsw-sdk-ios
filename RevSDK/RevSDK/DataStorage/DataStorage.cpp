//
//  DataStorage.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "DataStorage.hpp"
#include "Configuration.hpp"
#include "Data.hpp"
#import "NativeDataStorage.h"


namespace rs
{
    DataStorage::DataStorage()
    {
        mNativeDataStorage = new NativeDataStorage();
    }
    
    DataStorage::~DataStorage()
    {
        delete mNativeDataStorage;
    }

    void DataStorage::saveConfiguration(const Configuration& aConfiguration)
    {
        mNativeDataStorage->saveConfiguration(aConfiguration);
    }
    
    Configuration DataStorage::configuration()const
    {
        return mNativeDataStorage->configuration();
    }
    
    void DataStorage::saveRequestData(const Data& aRequestData)
    {
        mNativeDataStorage->saveRequestData(aRequestData);
    }
    
    std::vector<Data> DataStorage::loadRequestsData()
    {
        return mNativeDataStorage->loadRequestsData();
    }
    
    void DataStorage::deleteRequestsData()
    {
        mNativeDataStorage->deleteRequestsData();
    }
}