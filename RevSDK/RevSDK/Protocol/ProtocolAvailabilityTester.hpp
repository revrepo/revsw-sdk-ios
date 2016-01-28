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
        void connectionWasRedirected(std::shared_ptr<Connection> aConnection, std::shared_ptr<Request> aRequest, std::shared_ptr<Response> aResponse) override {};
        
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
        
        std::string          mCachedURL;
        
        void onTestResult(bool aSuccess);
        
        void initTester();
        
    public:
        ProtocolAvailabilityTester();
        
        void runTests(std::string aMonitoringURL, std::string aIgnoreProtocol, tCompletitionCB cbOnComplete);
        void runTests(std::string aMonitoringURL, tCompletitionCB cbOnComplete);
    };
}







