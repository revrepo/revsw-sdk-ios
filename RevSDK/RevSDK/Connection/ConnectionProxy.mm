//
//  ConnectionProxy.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <iostream>

#include "ConnectionProxy.h"
#include "Request.hpp"
#include "Model.hpp"
#include "Data.hpp"
#include "Response.hpp"
#include "Error.hpp"

namespace rs
{
    ConnectionProxy::ConnectionProxy(std::shared_ptr<Request> aRequest): mRequest(aRequest)
    {
        
    }
    
    ConnectionProxy::~ConnectionProxy()
    {
        
    }
    
    void ConnectionProxy::start()
    {
        std::shared_ptr<Connection> connection = Model::instance()->currentConnection();
        connection.get()->startWithRequest(mRequest, this);
    }
    
    void ConnectionProxy::setCallbacks(std::function<void()> aFinishCallback, std::function<void(Data)> aDataCallback, std::function<void(std::shared_ptr<Response>)> aResponseCallback, std::function<void(Error)> aErrorCallback)
    {
        mFinishRequestCallback    = aFinishCallback;
        mReceivedDataCallback     = aDataCallback;
        mReceivedResponseCallback = aResponseCallback;
        mErrorCallback            = aErrorCallback;
    }
    
    void ConnectionProxy:: connectionDidReceiveResponse(std::shared_ptr<Connection> aConnection, std::shared_ptr<Response> aResponse)
    {
        mReceivedResponseCallback(aResponse);
    }
    
    void ConnectionProxy:: connectionDidReceiveData(std::shared_ptr<Connection> aConnection, Data aData)
    {
        mReceivedDataCallback(aData);
    }
    
    void ConnectionProxy:: connectionDidFinish(std::shared_ptr<Connection> aConnection)
    {
        mFinishRequestCallback();
    }
    
    void ConnectionProxy:: connectionDidFailWithError(std::shared_ptr<Connection> aConnection, Error aError)
    {
        mErrorCallback(aError);
    }
}