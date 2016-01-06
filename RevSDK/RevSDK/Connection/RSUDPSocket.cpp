//
//  RSUDPSocket.cpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/5/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#include <iostream>
#include <boost/array.hpp>
#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <boost/date_time/posix_time/posix_time_types.hpp>

#include "RSUDPSocket.h"

namespace rs
{
    class UDPSocket::Impl
    {
    public:
        Impl():service(), socket(service), connected(false), deadline(service) {}
        ~Impl() {}
        
        boost::asio::io_service service;
        boost::asio::ip::udp::socket socket;
        boost::asio::ip::udp::endpoint endpoint;
        bool connected;
        boost::asio::deadline_timer deadline;
        
    };
    static void handle_receive(const boost::system::error_code& ec, std::size_t length,
                        boost::system::error_code* out_ec, std::size_t* out_length)
    {
        *out_ec = ec;
        *out_length = length;
    }
}

using namespace rs;

UDPSocket::UDPSocket(const std::string& aHost, int aPort):
    mImpl(nullptr),
    mHost(aHost),
    mPort(aPort)
{
    try
    {
        mImpl = new Impl();
    }
    catch (std::exception& e)
    {
        std::cout << "UDPSocket::UDPSocket exc: " << e.what() << std::endl;
        mImpl = nullptr;
    }
    
    if (valid())
    {
        mImpl->deadline.expires_at(boost::posix_time::pos_infin);
        p_checkDeadline();
    }
}

UDPSocket::~UDPSocket()
{
    close();
}

bool UDPSocket::connect()
{
    if (!valid())
        return false;
    
    if (mImpl->connected)
        return true;
    
    bool exc = false;
    try
    {
        char portStr[8];
        sprintf(portStr, "%d", mPort);
        boost::asio::ip::udp::resolver resolver(mImpl->service);
        boost::asio::ip::udp::resolver::query query(boost::asio::ip::udp::v4(), mHost, portStr);
        mImpl->endpoint = *resolver.resolve(query);
    }
    catch (std::exception& e)
    {
        std::cout << "UDPSocket::UDPSocket endpoint exc: " << e.what() << std::endl;
        exc = true;
    }
    
    if (!exc)
    {
        try
        {
            mImpl->socket.open(boost::asio::ip::udp::v4());
        }
        catch (std::exception& e)
        {
            std::cout << "UDPSocket::UDPSocket socket exc: " << e.what() << std::endl;
            exc = true;
        }
    }
    
    if (exc)
    {
        close();
        return false;
    }

    mImpl->connected = true;
    
    return true;
}

bool UDPSocket::connected() const
{
    if (!valid())
        return false;
    
    return mImpl->socket.is_open();
}

bool UDPSocket::send(const void* aData, size_t aSize)
{
    if (!valid())
        return false;
    
    if (aData == nullptr || aSize == 0)
    {
        std::cout << "UDPSocket::send error: " << "Invalid arguments" << std::endl;
        return false;
    }
    
    boost::system::error_code ec;
    mImpl->socket.send_to(boost::asio::buffer(aData, aSize), mImpl->endpoint, 0, ec);

    if (ec)
    {
        std::cout << "UDPSocket::send error: " << ec.value() << std::endl;
    }
    
    return ec == 0;
}

size_t UDPSocket::recv(void* aData, size_t aSize, size_t aTimeoutMS, bool* aTimoutFlag)
{
    if (!valid())
        return 0;
    
    if (aData == nullptr || aSize == 0)
    {
        std::cout << "UDPSocket::recv error: " << "Invalid arguments" << std::endl;
        return 0;
    }
    
    size_t res = 0;
    if (aTimeoutMS == 0)
    {
        boost::system::error_code ec;
        res = mImpl->socket.receive_from(boost::asio::buffer(aData, aSize), mImpl->endpoint, 0, ec);
        if (ec)
        {
            std::cout << "UDPSocket::recv error: " << ec.value() << std::endl;
            res = 0;
        }
    }
    else
    {
        boost::system::error_code ec;
        mImpl->deadline.expires_from_now(boost::posix_time::milliseconds(aTimeoutMS));
        ec = boost::asio::error::would_block;
        std::size_t length = 0;
        
        mImpl->socket.async_receive(boost::asio::buffer(aData, aSize),
                              boost::bind(&handle_receive, _1, _2, &ec, &length));
        
        do mImpl->service.run_one(); while (ec == boost::asio::error::would_block);
        res = length;
        
        if (aTimoutFlag != nullptr)
        {
            if (ec.value() == 89)
                *aTimoutFlag = true;
        }
    }

    return res;
}

void UDPSocket::close()
{
    if (!valid())
        return;
    
    if (mImpl->connected)
    {
        try
        {
            mImpl->socket.close();
        }
        catch (std::exception& e)
        {
            std::cout << "UDPSocket::recv close: " << e.what() << std::endl;
        }
    }

    delete mImpl;
    mImpl = nullptr;
}

void UDPSocket::p_checkDeadline()
{
    if (mImpl->deadline.expires_at() <= boost::asio::deadline_timer::traits_type::now())
    {
        mImpl->socket.cancel();
        
        mImpl->deadline.expires_at(boost::posix_time::pos_infin);
    }
    
    mImpl->deadline.async_wait(boost::bind(&UDPSocket::p_checkDeadline, this));
}
