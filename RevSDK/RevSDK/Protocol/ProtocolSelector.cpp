//
//  LastMileProtocolSelector.cpp
//  RevSDK
//
//  Created by Vlad Joss on 04.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#include <string>
#include "ProtocolSelector.hpp"

using namespace rs;


ProtocolSelector::ProtocolSelector() : mEventsHandler(this)
{
    
}

void ProtocolSelector::refreshTestInfo()
{
    mTester.runTests(mMonitoringURL, [this] (std::vector<AvailabilityTestResult> aResults){
        std::vector<std::string> allowedProtocols;
    });
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
}












