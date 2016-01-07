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
    if (vec.size() > 0)
    {
        convertIDsToPropocols(vec);
    }
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
            
            convertIDsToPropocols(allowedProtocols);
            sortProtocols(confProtos);
            this->saveAvailable();
        });
    } 
}

void ProtocolSelector::convertIDsToPropocols(std::vector<std::string> aVec)
{
    mSortedProtocols.clear();
    
    for (auto& it: aVec)
    {
        if (quicProtocolName() == it)
        {
            mSortedProtocols.push_back(std::make_shared<QUICProtocol>());
        }
        else if (standardProtocolName() == it)
        {
            mSortedProtocols.push_back(std::make_shared<StandardProtocol>());
        }
        ///add more
    }
}

void ProtocolSelector::saveAvailable()
{
    std::vector<std::string> ids;
    for (auto it: mSortedProtocols)
    {
        ids.push_back(it->protocolName());
    }
    data_storage::saveAvailableProtocols(ids);
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
    return !mSortedProtocols.empty();
}

void ProtocolSelector::sortProtocols(std::vector<std::string> aProtocolNamesOrdered)
{
    if (!mSortedProtocols.empty() && !aProtocolNamesOrdered.empty())
    {
        if(mSortedProtocols.front()->protocolName() == aProtocolNamesOrdered.front())
        {
            return;
        }
        
        //delete not allowed protos
        std::remove_if(aProtocolNamesOrdered.begin(),
                       aProtocolNamesOrdered.end(),[this](const std::string& item){
                           auto elem = std::find_if(mSortedProtocols.begin(), mSortedProtocols.end(), [item](std::shared_ptr<Protocol> it)
                           {
                               return  item == it->protocolName();
                           });
                           
                           return mSortedProtocols.end() == elem;
                       });
        
        convertIDsToPropocols(aProtocolNamesOrdered);
        
        if (mSortedProtocols.empty())
        {
            
        }
        
        //save
        saveAvailable();
    }
    else if (aProtocolNamesOrdered.empty())
    {
        mSortedProtocols.clear();
    }
}

std::shared_ptr<Protocol> ProtocolSelector::bestProtocol()
{
//    // TODO :: !!!!!!!!
//    return std::make_shared<QUICProtocol>();
    std::lock_guard<std::mutex> lockGuard(mLock);
    if (!mSortedProtocols.empty())
    {
        return mSortedProtocols.front()->clone();
    }
    // TODO :: !!!!!!!!
    return std::make_shared<StandardProtocol>();
}

void ProtocolSelector::onConfigurationApplied(std::shared_ptr<const Configuration> aConf)
{
    std::lock_guard<std::mutex> lockGuard(mLock);
    this->mMonitoringURL = aConf->transportMonitoringURL;
    
    if (mEventsHandler.isInitialized() == false)
    {
        std::vector<std::string> vec;
        vec.push_back(aConf->initialTransportProtocol);
        
        this->convertIDsToPropocols(vec);
        saveAvailable();
        this->refreshTestInfo();
    }
    else
    {
        this->sortProtocols(aConf->allowedProtocols);
    }
}












