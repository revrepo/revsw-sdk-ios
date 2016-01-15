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

#include <iostream>

#include "ConnectionProxy.h"
#include "Request.hpp"
#include "Model.hpp"
#include "Data.hpp"
#include "Response.hpp"
#include "Error.hpp"

#include "ProtocolFailureMonitor.h"

namespace rs
{
    ConnectionProxy::ConnectionProxy(std::shared_ptr<Request> aRequest, const std::string& aCurrentProtocolName): mRequest(aRequest)
    {
        mConnection = Model::instance()->connectionForProtocolName(aCurrentProtocolName);
    }
    
    ConnectionProxy::~ConnectionProxy()
    {
        
    }
    
    void ConnectionProxy::start()
    {
        mConnection.get()->startWithRequest(mRequest, this);
        ProtocolFailureMonitor::logConnection(mConnection->edgeTransport());
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
        ProtocolFailureMonitor::logFailure(aConnection->edgeTransport(), aError.code);
        mErrorCallback(aError);
    }
}