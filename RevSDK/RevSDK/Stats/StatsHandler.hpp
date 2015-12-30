//
//  StatsHandler.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef StatsHandler_hpp
#define StatsHandler_hpp

#include <stdio.h>
#include <memory>

#include "Utils.hpp"
#include "Data.hpp"
#include "ReportTransaction.h"

namespace rs
{
    class NativeStatsHandler; 
    class RequestStatsHandler;
    class Event;
    
    class StatsHandler
    {        
        std::unique_ptr<RequestStatsHandler> mRequestStatsHandler;
        std::unique_ptr<NativeStatsHandler> mStatsHandler;
        
        RSStatsReportingLevel mStatsReportingLevel;
        
    public:
     
        StatsHandler();
        ~StatsHandler();
        
        void setReportingLevel(RSStatsReportingLevel);
        void addRequestData(const Data&);
        
        bool hasRequestsData() const;
        
        ReportTransactionHanle createSendTransaction(int aRequestCount);
        
        void addEvent(const Event&);
    };
}

#endif /* StatsHandler_hpp */
