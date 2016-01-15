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

#include <memory>
#include <mutex>

#include "Protocol.hpp"
#include "StandardProtocol.hpp"
#include "QUICProtocol.hpp"
#include "Configuration.hpp"

#include "NativeNetworkEventsHandler.hpp"
#include "ProtocolAvailabilityTester.hpp"

namespace rs
{
    class ProtocolSelector : INetworkEventsDelegate
    {
    private:
        NativeNetworkEventsHandler  mEventsHandler;
        ProtocolAvailabilityTester  mTester;
        
        std::mutex                  mLock;
        
        std::string                 mMonitoringURL;
        
        std::shared_ptr<Protocol>   mBestProtocol;
        
        std::vector<std::string>    mAvailableProtocols;
        std::vector<std::string>    mIgnoredProtocols;
        
        void refreshTestInfo();
        
        void handleTestResults(std::vector<AvailabilityTestResult> aResults);
        
        void convertIDToPropocol(const std::string& aID);
        
        void sortProtocols(std::vector<std::string> aProtocolNamesOrdered);
        
        void saveAvailable(); 
        
    public:
        ProtocolSelector();
        ~ProtocolSelector() = default;
        
        std::shared_ptr<Protocol> bestProtocol();
        
        bool haveAvailadleProtocols();
        
        virtual void onNetworkTechnologyChanged() override;
        virtual void onCelluarStandardChanged() override;
        virtual void onSSIDChanged() override;
        
        virtual void onFirstInit() override;
        
        void onConfigurationApplied(std::shared_ptr<const Configuration>);
    };
}

