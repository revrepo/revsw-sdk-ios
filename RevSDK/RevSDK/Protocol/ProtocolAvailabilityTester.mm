//
//  ProtocolAvailabilityTester.cpp
//  RevSDK
//
//  Created by Vlad Joss on 04.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#include "RSReachability.h"

#include "RSUtils.h"
#include "ProtocolAvailabilityTester.hpp"
#include "Model.hpp"

using namespace rs;

ProtocolAvailabilityTester::ProtocolAvailabilityTester() : mRunning(false)
{
    
}


void ProtocolAvailabilityTester::runTests(std::string aMonitoringURL, std::function<void(std::vector<AvailabilityTestResult>)> cbOnComplete)
{
    if (!mRunning.exchange(true))
    {
        std::vector<AvailabilityTestResult> results;
        /////////////////////////////////////////////
        
        
        
        
        
        /////////////////////////////////////////// 
        cbOnComplete(results);
    }
}



