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

#include "Network.hpp"
#include "Data.hpp"
#include "Error.hpp"
#include "Response.hpp"
#include "NativeNetwork.h"
#include "Utils.hpp"
#include "Protocol.hpp"
#include "Connection.hpp"
#include "StandardConnection.hpp"
#include "QUICConnection.hpp"

#include "RSLog.h"

#include "Request.hpp"

namespace rs
{
    NativeNetwork* Network::mNativeNetwork = nullptr;
    
    Network::Network()
    {
        static std::atomic<bool> guard(false);
        if (guard.exchange(true))
        {
            mNativeNetwork = new NativeNetwork;
        }
    }
    
    Network::~Network()
    {
    }
    
    void Network::performRequest(std::string aURL, std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        std::function<void(const Data&, const Response&, const Error&)> completion = [=](const Data& aData, const Response& aResponse, const Error& aError){
            
            aCompletionBlock(aData, aError);
        };
        
        mNativeNetwork->performRequest(aURL, completion);
    }
    
    void Network::performRequest(std::string aURL, const Data& aBody, std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        std::function<void(const Data&, const Response&, const Error&)> completion = [=](const Data& aData, const Response& aResponse, const Error& aError){
            
            aCompletionBlock(aData, aError);
        };
        
        mNativeNetwork->performRequest(aURL, aBody, completion);
    }
    
    void Network::loadConfiguration(const std::string& aLoadURL, std::function<void(const Data&, const Error&)> aCompletionBlock)
    {
        performRequest(aLoadURL, aCompletionBlock);
    }
    
    void Network::sendStats(std::string aURL,const Data& aStatsData, std::function<void(const Error&)> aCompletionBlock)
    {
        std::function<void(const Data&, const Error&)> c = [=](const Data& aData, const Error& aError){
            
            if (aCompletionBlock)
            {
                aCompletionBlock(aError);
            }
        };
        
        performRequest(aURL, aStatsData, c);
    }
    
    void Network::performReques(std::shared_ptr<Protocol> aProtocol, std::string aURL, rs::ConnectionDelegate* aDelegate)
    {
        auto getConnectionFromProto = [](std::string protocolName) {
            if (protocolName == standardProtocolName())
            {
                Log::info(kLogTagSDKLastMile, "...sending standard test request...");
                return Connection::create<StandardConnection>();
            }
            else if (protocolName == quicProtocolName())
            {
                Log::info(kLogTagSDKLastMile, "...sending quic test request...");
                return Connection::create<QUICConnection>();
            }
            else
            {
                assert(false);
            }
        };
        
        std::shared_ptr<Connection> connection = getConnectionFromProto(aProtocol->protocolName()); 
        std::shared_ptr<rs::Request> req = mNativeNetwork->testRequestByURL(aURL, aProtocol.get());
        
        Log::info(kLogTagSDKLastMile, ("...request processed, headers set, sending to " + aURL).c_str());
        
        connection->startWithRequest(req, aDelegate);
    }
}
















