/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

#ifndef RequestStatsHandler_hpp
#define RequestStatsHandler_hpp

#include <stdio.h>
#include <vector>
#include <memory>

#include <mutex>
#include <atomic>

#include "ReportTransaction.h"
#include "LeakDetector.h"

namespace rs
{
    class Data;
    
    class RequestStatsHandler
    {
        REV_LEAK_DETECTOR(RequestStatsHandler);
        
        void deleteRequestsData();
        std::vector<Data> mRequestsDataVector;
        
        std::vector<Transaction> mSentData;
        
        void restoreTransaction(const int64_t key);
        void deleteTransaction (const int64_t key);
        
        Transaction createTransaction(int32_t aReqestsCountPerTransact);
        
    public:
        
        RequestStatsHandler();
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
