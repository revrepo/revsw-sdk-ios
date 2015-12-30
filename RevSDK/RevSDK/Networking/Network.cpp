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
#include "Utils.hpp"

namespace rs
{
    NativeNetwork* Network::mNativeNetwork = nullptr;
    
    Network::Network()
    {
        static std::atomic<bool> guard(false);
        if (guard.exchange(true))
        {
            mNativeNetwork = new NativeNetwork;
        }
    }
    
    Network::~Network()
    {
    }
    
    void Network::performRequest(std::string aURL, std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        std::function<void(const Data&, const Response&, const Error&)> completion = [=](const Data& aData, const Response& aResponse, const Error& aError){
            
            aCompletionBlock(aData, aError);
        };
        
        mNativeNetwork->performRequest(aURL, completion);
    }
    
    void Network::performRequest(std::string aURL, const Data& aBody, std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        std::function<void(const Data&, const Response&, const Error&)> completion = [=](const Data& aData, const Response& aResponse, const Error& aError){
            
            aCompletionBlock(aData, aError);
        };
        
        mNativeNetwork->performRequest(aURL, aBody, completion);
    }
    
    void Network::loadConfiguration(const std::string& aSDKKey, std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        std::string URL = loadConfigurationURL(aSDKKey);
        performRequest(URL, aCompletionBlock);
    }
    
    void Network::sendStats(std::string aURL,const Data& aStatsData, std::function<void(const Error&)> aCompletionBlock)
    {
        std::function<void(const Data&, const Error&)> c = [=](const Data& aData, const Error& aError){
            
            if (aCompletionBlock)
            {
                aCompletionBlock(aError);
            }
        };
        
        performRequest(aURL, aStatsData, c);
    }
}


