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
//#include "RSUtils.h"

namespace rs
{
    class StandardProtocol : public Protocol
    {
    public:
        
        std::string protocolName(); 
    };
}

#endif /* StandardProtocol_hpp */
