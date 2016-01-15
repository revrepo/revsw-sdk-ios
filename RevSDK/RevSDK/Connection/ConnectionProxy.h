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

#ifndef ConnectionProxy_hpp
#define ConnectionProxy_hpp

#include <stdio.h>
#include <memory>

#include "Connection.hpp"

namespace rs
{
    class Connection;
   class Request;
   class Response;
   class Data;
   class Error;
    
    class ConnectionProxy : public ConnectionDelegate
   {
       std::shared_ptr<Request> mRequest;
       std::shared_ptr<Connection> mConnection;
       
       std::function<void()> mFinishRequestCallback;
       std::function<void(Data)> mReceivedDataCallback;
       std::function<void(std::shared_ptr<Response>)> mReceivedResponseCallback;
       std::function<void(Error)> mErrorCallback;
       
     public:
       ConnectionProxy(std::shared_ptr<Request> aRequest, const std::string& aCurrentProtocolName);
       ~ConnectionProxy();
       void start();
       void setCallbacks(std::function<void()>, std::function<void(Data)>, std::function<void(std::shared_ptr<Response>)>, std::function<void(Error)>);
       
       //delegate
       virtual void connectionDidReceiveResponse(std::shared_ptr<Connection> aConnection, std::shared_ptr<Response> aResponse);
       virtual void connectionDidReceiveData(std::shared_ptr<Connection> aConnection, Data aData);
       virtual void connectionDidFinish(std::shared_ptr<Connection> aConnection);
       virtual void connectionDidFailWithError(std::shared_ptr<Connection> aConnection, Error aError);
   };
}

#endif /* ConnectionProxy_hpp */
