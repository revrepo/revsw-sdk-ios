//
//  RequestStatsHandler.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "RequestStatsHandler.hpp"
#include "Data.hpp"
#include "DataStorage.hpp"

namespace rs
{
    RequestStatsHandler::RequestStatsHandler(DataStorage* aDataStorage)
    {
        mDataStorage        = aDataStorage;
        mRequestsDataVector = mDataStorage->loadRequestsData();
    }
    
    void RequestStatsHandler::addNewRequestData(const Data& aRequestData)
    {
        mDataStorage->saveRequestData(aRequestData);
    }
}
