//
//  LastMileProtocolSelector.cpp
//  RevSDK
//
//  Created by Vlad Joss on 04.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#include <string>

#include "Model.hpp"
#include "DataStorage.hpp"
#include "ProtocolSelector.hpp"

using namespace rs;

ProtocolSelector::ProtocolSelector() : mEventsHandler(this)
{
    auto vec = data_storage::restoreAvailableProtocols();
    mAvailableProtocols = vec;
}

void ProtocolSelector::refreshTestInfo()
{
    if (mMonitoringURL != "")
    {
        mTester.runTests(mMonitoringURL, [this] (std::vector<AvailabilityTestResult> aResults){
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
            mAvailableProtocols = allowedProtocols;
            
            sortProtocols(confProtos);
        });
    } 
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
    this->refreshTestInfo();
}

void ProtocolSelector::onNetworkTechnologyChanged()
{
    this->refreshTestInfo();
}

void ProtocolSelector::onSSIDChanged()
{
    this->refreshTestInfo();
}

void ProtocolSelector::onFirstInit()
{
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
        if(mBestProtocol && (mBestProtocol->protocolName() == dbg))
        {
            return;
        }
        
        //delete not allowed protos
        std::remove_if(aProtocolNamesOrdered.begin(),
                       aProtocolNamesOrdered.end(),[this](const std::string& item){
                           auto elem = std::find_if(mAvailableProtocols.begin(), mAvailableProtocols.end(), [item](std::string& it)
                           {
                               return  item == it;
                           });
                           
                           return mAvailableProtocols.end() == elem;
                       });
        
        convertIDToPropocol(aProtocolNamesOrdered.front());
        
        //save
        saveAvailable();
    }
    else if (aProtocolNamesOrdered.empty())
    {
        mBestProtocol = nullptr;
    }
}

std::shared_ptr<Protocol> ProtocolSelector::bestProtocol()
{
//    return std::make_shared<StandardProtocol>();
    std::lock_guard<std::mutex> lockGuard(mLock);
    if (mBestProtocol && mAvailableProtocols.size())
    {
        std::cout<<"|| ========= PICKING PROTOCOL :: " + mBestProtocol->protocolName()<<std::endl;
        return mBestProtocol->clone();
    }
    // TODO :: !!!!!!!!
    std::cout<<"|| ========= PICKING PROTOCOL :: standard"<<std::endl;
    
    return std::make_shared<StandardProtocol>();
}

void ProtocolSelector::onConfigurationApplied(std::shared_ptr<const Configuration> aConf)
{
    std::lock_guard<std::mutex> lockGuard(mLock);
    this->mMonitoringURL = aConf->transportMonitoringURL;
    
    if (mEventsHandler.isInitialized() == false)
    {
        this->convertIDToPropocol(aConf->initialTransportProtocol);
        mAvailableProtocols.push_back(aConf->initialTransportProtocol);
        saveAvailable();
        this->refreshTestInfo();
    }
    else
    {
        this->sortProtocols(aConf->allowedProtocols);
    }
}












