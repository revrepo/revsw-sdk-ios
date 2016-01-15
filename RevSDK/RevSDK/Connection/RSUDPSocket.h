/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

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
