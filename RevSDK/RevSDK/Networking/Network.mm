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
#include "RSUtils.h"

#ifdef __APPLE__
#include "RSNativeNetwork.h"
#endif

namespace rs
{
    Network::Network()
    {
#ifdef __APPLE__
        nativeNetwork = (void *)CFBridgingRetain([[RSNativeNetwork alloc] init]);
#endif
    }
    
    void Network::loadConfigurationWithCompletionBlock(std::function<void(Data, Error)> aCompletionBlock)
    {
#ifdef __APPLE__
        
        void (^completionBlock)(NSData* , NSURLResponse*, NSError*) = ^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
            
            Data data   = dataFromNSData(aData);
            Error error = errorFromNSError(aError);
            
            aCompletionBlock(data, error);
        };
        
        [(__bridge RSNativeNetwork *)nativeNetwork loadConfigurationWithCompletionBlock:completionBlock];
#endif
    }
}


