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

#ifndef StatsHandler_hpp
#define StatsHandler_hpp

#include <stdio.h>
#include <memory>

#include "Utils.hpp"
#include "Data.hpp"
#include "ReportTransaction.h"
#include "LeakDetector.h"

namespace rs
{
    class NativeStatsHandler; 
    class RequestStatsHandler;
    class Event;
    
    class StatsHandler
    {
        std::string mSDKKey;
        
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
        
        void startMonitoring();
        void stopMonitoring();
        
        void setSDKKey(const std::string&);
    };
}

#endif /* StatsHandler_hpp */
