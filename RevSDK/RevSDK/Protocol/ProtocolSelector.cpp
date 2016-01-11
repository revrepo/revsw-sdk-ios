//
//  LastMileProtocolSelector.cpp
//  RevSDK
//
//  Created by Vlad Joss on 04.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#include <string>

#include "RSLog.h"

#include "Model.hpp"
#include "DataStorage.hpp"
#include "ProtocolSelector.hpp"
#include "ProtocolFailureMonitor.h"
#include "Utils.hpp"

using namespace rs;

ProtocolSelector::ProtocolSelector() : mEventsHandler(this)
{
    auto vec = data_storage::restoreAvailableProtocols();
    mAvailableProtocols = vec; 
    
    ProtocolFailureMonitor::subscribeOnProtocolFailed(ProtocolFailureMonitor::kSubscriberKey_Selector, [this](const std::string& aFailedProtocol){
        std::lock_guard<std::mutex> lockGuard(mLock);
        
        Log::info(kLogTagSDKLastMile, "Last mile protocol testing...");
        if (mMonitoringURL != "")
        {
            mTester.runTests(mMonitoringURL, aFailedProtocol, [this] (std::vector<AvailabilityTestResult> aResults){
                this->handleTestResults(aResults);
            });
        }
    });
}

void ProtocolSelector::refreshTestInfo()
{
    Log::info(kLogTagSDKLastMile, "Last mile protocol testing...");
    if (mMonitoringURL != "")
    {
        mTester.runTests(mMonitoringURL, [this] (std::vector<AvailabilityTestResult> aResults){
            this->handleTestResults(aResults);
        });
    } 
}

void ProtocolSelector::handleTestResults(std::vector<AvailabilityTestResult> aResults)
{
    auto confProtos = Model::instance()->getAllowedProtocolIDs();
    
    std::lock_guard<std::mutex> lockGuard(mLock);
    std::vector<std::string> allowedProtocols;
    
    for (auto it: aResults)
    {
        if (it.Available)
        {
            allowedProtocols.push_back(it.ProtocolID);
        }
    }
    
    if (allowedProtocols.size() == 0)
    {
        if (internetConnectionAvailable())
        {
            Model::instance()->addEvent(kLogLevelError, 1, "Failed to connect to Rev edge proxy service", 0.f, kRSLoggingLevelError);
        }
    }
    
    mAvailableProtocols = allowedProtocols;
    
    std::string toString = "ProtocolSelector:: finished testing. Available protocols:: ";
    
    for (auto& it: mAvailableProtocols)
    {
        toString += it + ", ";
    }
    Log::info(kLogTagSDKLastMile, toString.c_str());
    
    sortProtocols(confProtos);
}

void ProtocolSelector::convertIDToPropocol(const std::string& aID)
{
    if (quicProtocolName() == aID)
    {
        mBestProtocol = (std::make_shared<QUICProtocol>());
    }
    else if (standardProtocolName() == aID)
    {
        mBestProtocol = (std::make_shared<StandardProtocol>());
    }
    else
    {
        mBestProtocol = nullptr;
    }
}

void ProtocolSelector::saveAvailable()
{
    data_storage::saveAvailableProtocols(mAvailableProtocols);
}

void ProtocolSelector::onCelluarStandardChanged()
{
    ProtocolFailureMonitor::clear();
    Log::info(kLogTagSDKLastMile, "ProtocolSelector:: networks state changed");
    this->refreshTestInfo();
}

void ProtocolSelector::onNetworkTechnologyChanged()
{
    ProtocolFailureMonitor::clear();
    Log::info(kLogTagSDKLastMile, "ProtocolSelector:: networks state changed");
    this->refreshTestInfo();
}

void ProtocolSelector::onSSIDChanged()
{
    ProtocolFailureMonitor::clear();
    Log::info(kLogTagSDKLastMile, "ProtocolSelector:: networks state changed");
    this->refreshTestInfo();
}

void ProtocolSelector::onFirstInit()
{
    Log::info(kLogTagSDKLastMile, "ProtocolSelector:: First init");
    this->refreshTestInfo();
}

bool ProtocolSelector::haveAvailadleProtocols()
{ 
    std::lock_guard<std::mutex> lockGuard(mLock);
    return mBestProtocol.get() != nullptr;
}

void ProtocolSelector::sortProtocols(std::vector<std::string> aProtocolNamesOrdered)
{
    if (!mAvailableProtocols.empty() && !aProtocolNamesOrdered.empty())
    {
        std::string dbg = aProtocolNamesOrdered.front();
        
        //delete not allowed protos
        std::remove_if(aProtocolNamesOrdered.begin(),
                       aProtocolNamesOrdered.end(),[this](const std::string& item){
                           auto elem = std::find_if(mAvailableProtocols.begin(), mAvailableProtocols.end(), [item](std::string& it)
                           {
                               return  item == it;
                           });
                           
                           return mAvailableProtocols.end() == elem;
                       });
        
        if(aProtocolNamesOrdered.size())
        {
            convertIDToPropocol(aProtocolNamesOrdered.front());
            
            Log::info(kLogTagSDKLastMile,
                      std::string("ProtocolSelector:: picked protocol : : " + aProtocolNamesOrdered.front()).c_str());
            //save
            saveAvailable();
        }
        else
        {
            mBestProtocol = nullptr;
            
            Log::warning(kLogTagSDKLastMile,
                         "None of allowed protocols are available");
        }
    }
    else if (aProtocolNamesOrdered.empty())
    {
        mBestProtocol = nullptr;
        
        Log::warning(kLogTagSDKLastMile,
                     "None of allowed protocols found in configuration");
    }
}

std::shared_ptr<Protocol> ProtocolSelector::bestProtocol()
{
    //return std::make_shared<QUICProtocol>();
    std::lock_guard<std::mutex> lockGuard(mLock);
    if (mBestProtocol/* && mAvailableProtocols.size()*/)
    {
        Log::info(kLogTagSDKLastMile, (mBestProtocol->protocolName() + " Protcol name is being used").c_str());
        
        return mBestProtocol->clone();
    }
    Log::error(kLogTagSDKLastMile, "Asking for best protocol when none of them are available");
    
    return std::make_shared<StandardProtocol>();
}

void ProtocolSelector::onConfigurationApplied(std::shared_ptr<const Configuration> aConf)
{
    static std::atomic<bool> _firstInit(true);
    
    {
        std::lock_guard<std::mutex> lockGuard(mLock);
        this->mMonitoringURL = aConf->transportMonitoringURL;
    }
    
//  if (mEventsHandler.isInitialized() == false)
    if (_firstInit.exchange(false))
    {
        {
            std::lock_guard<std::mutex> lockGuard(mLock);
            this->convertIDToPropocol(aConf->initialTransportProtocol);
            
            Log::info(kLogTagSDKLastMile,
                      std::string("ProtocolSelector:: picked initial protocol : " + aConf->initialTransportProtocol).c_str());
            
            mAvailableProtocols.push_back(aConf->initialTransportProtocol);
            saveAvailable();
        }

        this->refreshTestInfo();
    }
    else
    {
        std::string toString = "ProtocolSelector:: Configuration applied. Available protocols:: ";
        
        for (auto& it: mAvailableProtocols)
        {
            toString += it + ", ";
        }
        Log::info(kLogTagSDKLastMile, toString.c_str());
        toString = "ProtocolSelector:: configuration applied. Allowed protocols:: ";
        
        for (auto& it: mAvailableProtocols)
        {
            toString += it + ", ";
        }
        Log::info(kLogTagSDKLastMile, toString.c_str());
        
        this->sortProtocols(aConf->allowedProtocols);
    }
}

