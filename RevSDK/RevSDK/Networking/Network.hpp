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
        NativeNetwork* nativeNetwork;
        
        public:
        
        Network();
        ~Network();
        
        void loadConfigurationWithCompletionBlock(std::function<void(const Data&, const Error&)>);
    };
}

#endif /* Network_hpp */
