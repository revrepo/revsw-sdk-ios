//
//  ProtocolAvailabilityTester.cpp
//  RevSDK
//
//  Created by Vlad Joss on 04.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#include "RSUtils.h"
#include "ProtocolAvailabilityTester.hpp"
#include "QUICProtocol.hpp"
#include "StandardProtocol.hpp"

#include "Model.hpp"

using namespace rs;

ProtocolAvailabilityTester::ProtocolAvailabilityTester() :
mRunning(false)
{
    mConnectionEventHandler = MockDelegate([this](bool succes){
        this->onTestResult(succes);
    });
}

void ProtocolAvailabilityTester::onTestResult(bool aSuccess)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        AvailabilityTestResult result;
        
        result.Available = aSuccess;
        result.ProtocolID = mProtocolsToTest.top()->protocolName();
        
        mCurrentResults.push_back(result);
        mProtocolsToTest.pop();
        
        if (mProtocolsToTest.empty())
        {
            mCompletitionCallback(mCurrentResults);
            mCurrentResults.clear();
            mRunning.store(false);
        }
        else
        { 
            mNetwork.performReques(mProtocolsToTest.top()->clone(), mCachedURL, &mConnectionEventHandler);
        }
    });
}

void ProtocolAvailabilityTester::runTests(std::string aMonitoringURL, std::function<void(std::vector<AvailabilityTestResult>)> cbOnComplete)
{
    if (!mRunning.exchange(true))
    {
        /////////////////////////////////////////////
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            initTester();
            mCompletitionCallback = cbOnComplete;
            mCachedURL = aMonitoringURL;
            mNetwork.performReques(mProtocolsToTest.top()->clone(), aMonitoringURL, &mConnectionEventHandler);
        });
        ///////////////////////////////////////////
    }
}

void ProtocolAvailabilityTester::initTester()
{
    mCurrentResults.clear();
    mProtocolsToTest = std::stack<std::shared_ptr<Protocol>>();
    
    mProtocolsToTest.push(std::make_shared<QUICProtocol>());
    mProtocolsToTest.push(std::make_shared<StandardProtocol>() );
}


