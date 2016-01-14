//
//  Protocol.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Protocol_hpp
#define Protocol_hpp

#include <stdio.h>
#include <string>

#include <memory>
#include "LeakDetector.h"

namespace rs
{
    class Protocol
    {
        REV_LEAK_DETECTOR(Protocol);
        
    public:
        virtual std::shared_ptr<Protocol> clone() = 0;
        
        virtual std::string protocolName() = 0;
    };
}

#endif /* Protocol_hpp */
