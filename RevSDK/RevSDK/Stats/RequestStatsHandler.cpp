//
//  RequestStatsHandler.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//
#include <assert.h>
#include "RequestStatsHandler.hpp"
#include "Data.hpp"
#include "DataStorage.hpp"
#include "JSONUtils.hpp"

namespace rs
{
    RequestStatsHandler::RequestStatsHandler(std::weak_ptr<DataStorage> aDataStorage)
    {
        mDataStorage        = aDataStorage;
        mRequestsDataVector = mDataStorage.lock()->loadRequestsData();
    }
    
    void RequestStatsHandler::addNewRequestData(const Data& aRequestData)
    {
        //std::lock_guard<std::mutex> lockGuard(mLock);
        mRequestsDataVector.push_back(aRequestData);
        mDataStorage.lock()->saveRequestData(aRequestData);
    }
    
    Transaction RequestStatsHandler::createTransaction(int32_t aReqestsCountPerTransact)
    {
        Transaction inst;
        
        assert(mRequestsDataVector.size());
        
        int32_t offset = aReqestsCountPerTransact;
        
        if (offset > mRequestsDataVector.size())
        {
            offset = (int32_t) mRequestsDataVector.size();
        }
        
        auto begin = inst.PendingData.begin();
        auto insStart = mRequestsDataVector.begin();
        std::vector<Data>::iterator insEnd = insStart + offset;
        
        if (offset == mRequestsDataVector.size())
        {
            assert(insEnd == mRequestsDataVector.end());
        }
        
        inst.PendingData.insert(begin, insStart, insEnd);
        
        
        assert(inst.PendingData.size());
        
        mRequestsDataVector.erase(insStart, insEnd);
        
        return std::move(inst);
    }
    
    ReportTransactionHanle RequestStatsHandler::requestsData(int32_t aRequestCount)
    {
        ReportTransactionHanle handle;
        
        Data jsonData = jsonDataFromDataVector(mRequestsDataVector);
        handle.Buffer = jsonData;
        
        if (mRequestsDataVector.empty())
        {
            return handle;
        }
        
        mSentData.push_back(createTransaction(aRequestCount));
        handle.Buffer = jsonDataFromDataVector(mSentData.back().PendingData);
        
        int64_t id = mSentData.back().ID;
        
        handle.cbOnFail = [this, id]{
            this->restoreTransaction(id);
        };
        
        handle.cbOnSuccess = [this, id]{
            this->deleteTransaction(id);
        };
        
        return handle;
    }
    
    void RequestStatsHandler::restoreTransaction(const int64_t key)
    {
        for (auto it = mSentData.begin(); it != mSentData.end(); ++it)
        {
            if (key == it->ID)
            {
                mRequestsDataVector.insert(mRequestsDataVector.end(),
                                           it->PendingData.begin(),
                                           it->PendingData.end());
                
                mSentData.erase(it);
                break;
            }
        }
    }
    
    void RequestStatsHandler::deleteTransaction (const int64_t key)
    {
        for (auto it = mSentData.begin(); it != mSentData.end(); ++it)
        {
            if (key == it->ID)
            {
                mSentData.erase(it);
                break;
            }
        }
        deleteRequestsData();
    }
    
    void RequestStatsHandler::deleteRequestsData()
    { 
        mDataStorage.lock()->deleteRequestsData();
        if (mRequestsDataVector.size() > 0)
        {
            mDataStorage.lock()->saveRequestDataVec(mRequestsDataVector);
        }
    }
}
