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

#include "Utils.hpp"
#include "RSUDPSocket.h"
#include "RSLog.h"

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
        Log::error(kLogTagQUICNetwork, "UDPSocket init: ", notNullString(e.what()));
        mImpl = nullptr;
    }
    
    if (valid())
    {
        mImpl->deadline.expires_at(boost::posix_time::pos_infin);
        p_checkDeadline();
        Log::info(kLogTagQUICNetwork, "UDPSocket initialized");
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
        Log::error(kLogTagQUICNetwork, "UDPSocket resolve: ", notNullString(e.what()));
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
            Log::error(kLogTagQUICNetwork, "UDPSocket connect: ", notNullString(e.what()));
            exc = true;
        }
    }
    
    if (exc)
    {
        close();
        return false;
    }

    mImpl->connected = true;
    Log::info(kLogTagQUICNetwork, "UDPSocket connected");
    
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
        Log::warning(kLogTagQUICNetwork, "UDPSocket send bad arguments");
        return false;
    }
    
    boost::system::error_code ec;
    mImpl->socket.send_to(boost::asio::buffer(aData, aSize), mImpl->endpoint, 0, ec);

    if (ec)
    {
        Log::error(kLogTagQUICNetwork, "UDPSocket send: %d %s", ec.value(), notNullString(ec.message()));
    }
    
    if (aSize > 0)
    {
        Traffic::logOut(kLogTagQUICNetwork, (int)aSize);
    }
    
    return ec == 0;
}

size_t UDPSocket::recv(void* aData, size_t aSize, size_t aTimeoutMS, bool& aTimeoutFlag, Error& aError)
{
    if (!valid())
        return 0;
    
    if (aData == nullptr || aSize == 0)
    {
        Log::warning(kLogTagQUICNetwork, "UDPSocket recv bad arguments");
        return 0;
    }
    
    size_t res = 0;
    if (aTimeoutMS == 0)
    {
        boost::system::error_code ec;
        res = mImpl->socket.receive_from(boost::asio::buffer(aData, aSize), mImpl->endpoint, 0, ec);
        if (ec)
        {
            Log::error(kLogTagQUICNetwork, "UDPSocket recv: %d %s", ec.value(), notNullString(ec.message()));
            mImpl->socket.close();
            mImpl->connected = false;
            aError.code = ec.value();
            aError.domain = "revsdk.quic.socket";
            aError.setDescription(ec.message());
            res = 0;
        }
        
        if (res > 0)
        {
            Traffic::logIn(kLogTagQUICNetwork, (int)res);
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
        
        if (ec.value() == 89) // timeout code magic number
        {
            aTimeoutFlag = true;
        }
        else if (ec)
        {
            aError.code = ec.value();
            aError.domain = "revsdk.quic.socket";
            aError.setDescription(ec.message());
            Log::error(kLogTagQUICNetwork, "UDPSocket recv: %d %s", ec.value(), notNullString(ec.message()));
            mImpl->socket.close();
            mImpl->connected = false;
        }
        else
        {
            // no error
        }
        
        if (res > 0)
        {
            Traffic::logIn(kLogTagQUICNetwork, (int)res);
        }
    }
    traceSocketSpeed((int)res);

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
            Log::error(kLogTagQUICNetwork, "UDPSocket close: %s", notNullString(e.what()));
        }
    }

    Log::info(kLogTagQUICNetwork, "UDPSocket closed");
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
