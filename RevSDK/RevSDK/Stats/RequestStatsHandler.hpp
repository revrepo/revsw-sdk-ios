//
//  RequestStatsHandler.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef RequestStatsHandler_hpp
#define RequestStatsHandler_hpp

#include <stdio.h>
#include <vector>
#include <memory>

#include <mutex>
#include <atomic>

#include "ReportTransaction.h"

namespace rs
{
    class Data;
    class DataStorage;
    
    class RequestStatsHandler
    {
        void deleteRequestsData();
        
        //std::mutex mLock;
        
        std::weak_ptr<DataStorage> mDataStorage;
        std::vector<Data> mRequestsDataVector;
        
        std::vector<Transaction> mSentData;
        
        void restoreTransaction(const int64_t key);
        void deleteTransaction (const int64_t key);
        
        Transaction createTransaction(int32_t aReqestsCountPerTransact);
        
    public:
        
        RequestStatsHandler(std::weak_ptr<DataStorage>);
        ~RequestStatsHandler(){};
        
        void addNewRequestData(const Data&);
        
        ReportTransactionHanle requestsData(int32_t aRequestCount);
        
        bool hasData() const
        {
            return !mRequestsDataVector.empty();
        }
    };
}

#endif /* RequestStatsHandler_hpp */
