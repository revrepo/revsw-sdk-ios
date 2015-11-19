//
//  ConnectionProxy.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <iostream>

#import <Foundation/Foundation.h>

#include "ConnectionProxy.h"
#include "RSUtils.h"
#include "Request.hpp"
#include "Model.hpp"
#include "Data.hpp"
#include "Response.hpp"

namespace rs
{
    ConnectionProxy::ConnectionProxy(NSURLRequest* aRequest)
    {
        mRequest = requestFromURLRequest(aRequest);
    }
    
    ConnectionProxy::~ConnectionProxy()
    {
        
    }
    
    void ConnectionProxy::start()
    {
        std::shared_ptr<Connection> connection = Model::instance()->currentConnection();
        connection.get()->startWithRequest(mRequest, this, connection);
    }
    
    void ConnectionProxy::setCallbacks(std::function<void()> aFinishCallback, std::function<void(Data)> aDataCallback, std::function<void(std::shared_ptr<Response>)> aResponseCallback)
    {
        mFinishRequestCallback    = aFinishCallback;
        mReceivedDataCallback     = aDataCallback;
        mReceivedResponseCallback = aResponseCallback;
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
}