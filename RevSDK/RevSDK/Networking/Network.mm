//
//  Network.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Network.hpp"
#include "Data.hpp"
#include "Error.hpp"
#include "Response.hpp"
#include "NativeNetwork.h"
#include "RSUtils.h"

namespace rs
{
    Network::Network()
    {
        nativeNetwork = new NativeNetwork;
    }
    
    Network::~Network()
    {
        delete nativeNetwork;
    }
    
    void Network::performRequest(std::string aURL, std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        std::function<void(const Data&, const Response&, const Error&)> completion = [=](const Data& aData, const Response& aResponse, const Error& aError){
            
            aCompletionBlock(aData, aError);
        };
        
        nativeNetwork->performRequest(aURL, completion);
    }
    
    void Network::performRequest(std::string aURL, const Data& aBody, std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        std::function<void(const Data&, const Response&, const Error&)> completion = [=](const Data& aData, const Response& aResponse, const Error& aError){
            
            aCompletionBlock(aData, aError);
        };
        
        nativeNetwork->performRequest(aURL, aBody, completion);
    }
    
    void Network::loadConfiguration(std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        std::string URL = loadConfigurationURL();
        performRequest(URL, aCompletionBlock);
    }
    
    void Network::sendStats(const Data& aStatsData, std::function<void(const Error&)> aCompletionBlock)
    {
        std::string URL = reportStatsURL();
        std::function<void(const Data&, const Error&)> c = [=](const Data& aData, const Error& aError){
            
            if (aCompletionBlock)
            {
                aCompletionBlock(aError);
            }
        };
        
        performRequest(URL, aStatsData, c);
    }
}


