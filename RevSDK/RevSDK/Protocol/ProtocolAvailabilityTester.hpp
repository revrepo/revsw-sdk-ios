//
//  ProtocolAvailabilityTester.hpp
//  RevSDK
//
//  Created by Vlad Joss on 04.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#pragma once 

#include <functional>
#include <vector>
#include <string>

#include <atomic>

namespace rs
{
    struct AvailabilityTestResult
    {
        std::string ProtocolID;
        bool        Reachable;
    };
    
    class ProtocolAvailabilityTester
    {
    private:
        std::atomic<bool> mRunning;
    public:
        ProtocolAvailabilityTester();
        
        void runTests(std::string aMonitoringURL, std::function<void(std::vector<AvailabilityTestResult>)> cbOnComplete);
    };
}
