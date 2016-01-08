//
//  LastMileProtocolSelector.hpp
//  RevSDK
//
//  Created by Vlad Joss on 04.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

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
        
        void refreshTestInfo();
        
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

