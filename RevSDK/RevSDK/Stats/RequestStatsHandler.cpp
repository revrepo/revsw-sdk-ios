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
#include "JSONUtils.hpp"

namespace rs
{
    RequestStatsHandler::RequestStatsHandler(DataStorage* aDataStorage)
    {
        mDataStorage        = aDataStorage;
        mRequestsDataVector = mDataStorage->loadRequestsData();
    }
    
    void RequestStatsHandler::addNewRequestData(const Data& aRequestData)
    {
        mRequestsDataVector.push_back(aRequestData);
        mDataStorage->saveRequestData(aRequestData);
    }
    
    Data RequestStatsHandler::requestsData()
    {
        return jsonDataFromDataVector(mRequestsDataVector);
    }
}
