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
#include <stack>
#include <assert.h>

#include <atomic>

#include "Error.hpp"
#include "Data.hpp"
#include "Response.hpp"

#include "Protocol.hpp"
#include "Connection.hpp"

#include "Network.hpp"

namespace rs
{
    struct AvailabilityTestResult
    {
        std::string ProtocolID;
        bool        Available;
    };
    
    class MockDelegate : public ConnectionDelegate
    {
    private:
        std::function<void(bool)> cbOnResponse;
    public:
        MockDelegate(){}
        MockDelegate(std::function<void(bool)> fOnRespoce): cbOnResponse(fOnRespoce)
        {
            assert(fOnRespoce);
        }
        
        void connectionDidReceiveData(std::shared_ptr<Connection> aConnection, Data aData) override {};
        void connectionDidFinish(std::shared_ptr<Connection> aConnection) override {};
        
        void connectionDidReceiveResponse(std::shared_ptr<Connection> aConnection, std::shared_ptr<Response> aResponse) override
        {
            cbOnResponse(aResponse->statusCode() == 200);
        };
        void connectionDidFailWithError(std::shared_ptr<Connection> aConnection, Error aError) override
        {
            cbOnResponse(false);
        };
    };
    
    class ProtocolAvailabilityTester
    {
    private:
        typedef std::function<void(std::vector<AvailabilityTestResult>)> tCompletitionCB;
        std::atomic<bool>   mRunning;
        MockDelegate        mConnectionEventHandler;
        
        std::vector<AvailabilityTestResult> mCurrentResults;
        
        std::stack<std::shared_ptr<Protocol>> mProtocolsToTest;
        
        tCompletitionCB      mCompletitionCallback;
        
        Network              mNetwork;
        
        void onTestResult(bool aSuccess);
        
        void initTester();
        
    public:
        ProtocolAvailabilityTester();
        
        void runTests(std::string aMonitoringURL, tCompletitionCB cbOnComplete);
    };
}







