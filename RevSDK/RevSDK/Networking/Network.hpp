//
//  Network.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Network_hpp
#define Network_hpp

#include <stdio.h>
#include <iostream>

namespace rs
{
    class Data;
    class Error;
    class NativeNetwork;
    
    class Network
    {
        static NativeNetwork* mNativeNetwork;
        
        void performRequest(std::string aURL, std::function<void(const Data&, const Error&)> aCompletionBlock);
        void performRequest(std::string aURL, const Data& aBody, std::function<void(const Data&, const Error&)> aCompletionBlock);
        
        public:
        
        Network();
        ~Network();
        
        void loadConfiguration(const std::string &, std::function<void(const Data&, const Error&)> aCompletionBlock);
        void sendStats(std::string aURL, const Data&, std::function<void(const Error&)>); 
    };
}

#endif /* Network_hpp */
