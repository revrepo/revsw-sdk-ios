//
//  NativeUDPSocketCPPDelegate.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#pragma once

#include "QUICHeaders.h"
#include "Error.hpp"

namespace rs
{
    class NativeUDPSocketCPPDelegate
    {
    public:
        NativeUDPSocketCPPDelegate() {}
        virtual ~NativeUDPSocketCPPDelegate() {}
        
        virtual bool onQUICPacket(const net::QuicEncryptedPacket &packet) = 0;
        virtual void onQUICError() = 0;
    };
}
