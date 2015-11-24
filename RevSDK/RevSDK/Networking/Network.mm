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
    
    void Network::loadConfigurationWithCompletionBlock(std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        std::function<void(const Data&, const Response&, const Error&)> completion = [=](const Data& aData, const Response& aResponse, const Error& aError){
        
            aCompletionBlock(aData, aError);
        };
        
        nativeNetwork->loadConfigurationWithCompletion(completion);
    }
}


