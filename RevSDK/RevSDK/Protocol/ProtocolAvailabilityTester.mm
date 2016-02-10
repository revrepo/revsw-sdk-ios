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

#include "RSUtils.h"
#include "ProtocolAvailabilityTester.hpp"
#include "QUICProtocol.hpp"
#include "StandardProtocol.hpp"
#include "Model.hpp"
#include "Utils.hpp"

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
        
        std::string message("Got a responce on a test request, "
                            + result.ProtocolID + " is " +(aSuccess ? "available" : " not available"));
        
        Log::info(kLogTagSDKLastMile, message.c_str());
        
        mCurrentResults.push_back(result);
        mProtocolsToTest.pop();
        
        if (mProtocolsToTest.empty())
        {
            mCompletitionCallback(mCurrentResults);
            mCurrentResults.clear();
            mRunning.store(false);
            postNotification("kProtocolTestingOverNotification");
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
            Model::instance()->addEvent(kLogLevelDebug, 2, "Protocol availability tests started", 0.f, kRSLoggingLevelDebug);
            initTester();
            mCompletitionCallback = cbOnComplete;
            mCachedURL = aMonitoringURL;
            mNetwork.performReques(mProtocolsToTest.top()->clone(), aMonitoringURL, &mConnectionEventHandler);
        });
        ///////////////////////////////////////////
    }
}


void ProtocolAvailabilityTester::runTests(std::string aMonitoringURL, std::string aIgnoreProtocol, std::function<void(std::vector<AvailabilityTestResult>)> cbOnComplete)
{
    if (!mRunning.exchange(true))
    {
        /////////////////////////////////////////////
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mCurrentResults.clear();
            mProtocolsToTest = std::stack<std::shared_ptr<Protocol>>();
            
            if (quicProtocolName() != aIgnoreProtocol)
            {
                mProtocolsToTest.push(std::make_shared<QUICProtocol>());
            }
            if (standardProtocolName() != aIgnoreProtocol)
            {
                mProtocolsToTest.push(std::make_shared<StandardProtocol>() );
            }
            
            mCompletitionCallback = cbOnComplete;
            mCachedURL = aMonitoringURL;
            mNetwork.performReques(mProtocolsToTest.top()->clone(), aMonitoringURL, &mConnectionEventHandler);
        });
        ///////////////////////////////////////////
    }
    else
    {
        Log::info(kLogTagSDKLastMile, "Trying to run tests while they are already running, pass");
    }
}

void ProtocolAvailabilityTester::initTester()
{
    mCurrentResults.clear();
    mProtocolsToTest = std::stack<std::shared_ptr<Protocol>>();
    
    mProtocolsToTest.push(std::make_shared<QUICProtocol>());
    mProtocolsToTest.push(std::make_shared<StandardProtocol>() );
}


