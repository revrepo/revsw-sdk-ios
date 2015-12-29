//
//  StatsStructs.h
//  RevSDK
//
//  Created by Vlad Joss on 29.12.15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

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
