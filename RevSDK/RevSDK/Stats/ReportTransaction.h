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

#ifndef StatsStructs_h
#define StatsStructs_h

#include <assert.h>
#include <functional>
#include <vector>
#include "Data.hpp"


namespace rs
{
    struct ReportTransactionHanle
    {
        std::function<void()> cbOnSuccess;
        std::function<void()> cbOnFail;
        Data Buffer;
    };
    
    struct Transaction
    {
    private:
        static int64_t gID;
        
    public:
        int64_t ID;
        std::vector<Data> PendingData;
        
        Transaction() : ID(++gID)
        { }
        
        ~Transaction()
        {
            assert(PendingData.size());
            PendingData.clear(); //dbg
        }
        
        Transaction& operator= (const Transaction& other)
        {
            ID = other.ID;
            PendingData = other.PendingData;
            return *this;
        }
        
        Transaction(const Transaction& aOther)
        {
            ID = aOther.ID;
            PendingData = aOther.PendingData;
        }
    };
}

#endif
