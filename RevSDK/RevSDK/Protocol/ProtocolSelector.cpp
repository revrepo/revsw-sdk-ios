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
            std::vector<std::string> allowedProtocols;
            
            for (auto it: aResults)
            {
                allowedProtocols.push_back(it.ProtocolID);
            }
            
            convertIDsToPropocols(allowedProtocols);
            sortProtocols(Model::instance()->getAllowedProtocolIDs());
            data_storage::saveAvailableProtocols(allowedProtocols);
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
        else if (httpsProtocolName() == it)
        {
            mSortedProtocols.push_back(std::make_shared<StandardProtocol>());
        }
        ///add more
    }
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

void ProtocolSelector::sortProtocols(std::vector<std::string> aProtocolNamesOrdered)
{
    if (!mSortedProtocols.empty() && !aProtocolNamesOrdered.empty())
    {
        if(mSortedProtocols.front()->protocolName() == aProtocolNamesOrdered.front())
        {
            return;
        }
        
        //delete not allowed protos
        for (auto it = mSortedProtocols.begin(); it != mSortedProtocols.end();)
        {
            std::vector<std::string>::iterator elem = std::find_if(aProtocolNamesOrdered.begin(),
                                                                                 aProtocolNamesOrdered.end(),
                                                                                 [it](const std::string& item){
                                                                                     
                                                                                     return  item == (*it)->protocolName();
                                                                                 });
            
            if (elem == aProtocolNamesOrdered.end())
            {
                it = mSortedProtocols.erase(it);
            }
            else
            {
                ++it;
            }
        }
        //sort
        for (auto it = aProtocolNamesOrdered.begin(); it != aProtocolNamesOrdered.end();)
        {
            std::vector<std::shared_ptr<Protocol>>::iterator elem = std::find_if(mSortedProtocols.begin(),
                         mSortedProtocols.end(),
                         [it](std::shared_ptr<Protocol> item){
                             
                return  item->protocolName() == *it;
            });
            
            std::shared_ptr<Protocol> val = *elem;
            
            if (elem != mSortedProtocols.end())
            {
                mSortedProtocols.erase(elem);
                mSortedProtocols.insert(mSortedProtocols.cbegin(), val);
                
                it = aProtocolNamesOrdered.erase(it);
            }
            else
            {
                ++it;
            }
        }
        
        //save
        std::vector<std::string> ids;
        for (auto it: mSortedProtocols)
        {
            ids.push_back(it->protocolName());
        }
        data_storage::saveAvailableProtocols(ids);
    }
    else if (aProtocolNamesOrdered.empty())
    {
        mSortedProtocols.clear();
    }
}

std::shared_ptr<Protocol> ProtocolSelector::bestProtocol()
{
    if (!mSortedProtocols.empty())
    {
        return mSortedProtocols.front()->clone();
    }
    // TODO :: !!!!!!!!
    return std::make_shared<StandardProtocol>();
}

void ProtocolSelector::onConfigurationApplied(std::shared_ptr<const Configuration> aConf)
{
    this->mMonitoringURL = aConf->transportMonitoringURL;
    this->sortProtocols(aConf->allowedProtocols);
    
    if (mEventsHandler.isInitialized() == false)
    {
        this->refreshTestInfo();
    }
}












