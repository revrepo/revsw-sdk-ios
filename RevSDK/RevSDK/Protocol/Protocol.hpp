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

namespace rs
{
    class Protocol
    {
    public:
        
        virtual std::string protocolName() = 0;
    };
}

#endif /* Protocol_hpp */
