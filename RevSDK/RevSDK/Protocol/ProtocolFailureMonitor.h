//
//  ProtocolFailureMonitor.h
//  RevSDK
//
//  Created by Vlad Joss on 09.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#pragma once 

#include <map>
#include <vector>
#include <chrono>
#include <mutex>
#include <functional>

#include "Utils.hpp"

namespace rs
{
    class ProtocolFailureMonitor
    {
    private:
        typedef std::chrono::system_clock::time_point tTimepoint;
        struct ErrorReport
        {
            ErrorReport(long aCode) : Code(aCode)
            {
                DateReported = std::chrono::system_clock::now();
            }
            ErrorReport(const ErrorReport& aOther) : Code(aOther.Code), DateReported(aOther.DateReported) {};
            
            long Code;
            
            tTimepoint DateReported;
        };
        
        std::map<std::string, std::vector<ErrorReport>> mReportMap;
        std::map<std::string, std::vector<tTimepoint>>  mLoggedConnections;
        
        std::map<size_t, std::function<void(const std::string&)>> cbOnProtocolFailed;
        
        const unsigned int kTimeoutSec = 300;
        /// TODO: Replace on config values
        const unsigned int kMinimumRequests = 4;
        const double kMinFailPercentToSwitchProto = 0.6;
        
        void validate(const std::string& aProtocolID);
        
        static std::mutex mLock;
        
        static ProtocolFailureMonitor* mInstanse;
        
    public:
        static const size_t kSubscriberKey_Selector = 0;
        
        static ProtocolFailureMonitor* getInstance();
        static void initialize();
        
        static void subscribeOnProtocolFailed(size_t, std::function<void(const std::string&)>);
        static void unsubscribe(size_t aID);
        
        static void logFailure(const std::string& aProtocolID, long aErrorCode);
        
        static void logConnection(const std::string& aProtocolID);
        
        static void clear();
    };
}












