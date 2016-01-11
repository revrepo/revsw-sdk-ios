//
//  RSUDPSocket.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/5/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#pragma once

#include <string>
#include "Error.hpp"

namespace rs
{
    class UDPSocket
    {
    public:
        UDPSocket(const std::string& aHost, int aPort);
        UDPSocket(const UDPSocket&) = delete;
        ~UDPSocket();
        UDPSocket& operator=(const UDPSocket&) = delete;
        
        bool valid() const { return mImpl != nullptr; }
        bool connected() const;

        bool connect();
        bool send(const void* aData, size_t aSize);
        size_t recv(void* aData, size_t aSize, size_t aTimeoutMS, bool& aTimeoutFlag, Error& aError);
        void close();
        
    private:
        void p_checkDeadline();
    private:
        class Impl;
        Impl* mImpl;
        std::string mHost;
        int mPort;
    };
}
