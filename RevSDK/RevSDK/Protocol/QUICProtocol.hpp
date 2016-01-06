//
//  QUICProtocol.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef QUICProtocol_hpp
#define QUICProtocol_hpp

#include <stdio.h>

#include "Protocol.hpp"

namespace rs
{
    class QUICProtocol : public Protocol
    {
    public:
        std::shared_ptr<Protocol> clone() { return std::make_shared<QUICProtocol>(); }
        
        std::string protocolName() { return "quic"; }
    };
}

#endif /* QUICProtocol_hpp */
