//
//  StandardProtocol.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef StandardProtocol_hpp
#define StandardProtocol_hpp

#include <stdio.h>

#include "Protocol.hpp"

namespace rs
{
    class StandardProtocol : public Protocol
    {
    public:
        std::shared_ptr<Protocol> clone() { return std::make_shared<StandardProtocol>(); }
        
        std::string protocolName(); 
    };
}

#endif /* StandardProtocol_hpp */
