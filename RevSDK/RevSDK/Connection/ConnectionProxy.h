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
#include "LeakDetector.h"

namespace rs
{
    class Connection;
   class Request;
   class Response;
   class Data;
   class Error;
    
   class ConnectionProxy : public ConnectionDelegate
   {
       REV_LEAK_DETECTOR(ConnectionProxy);
       
       std::shared_ptr<Request> mRequest;
       std::shared_ptr<Connection> mConnection;
       
       std::function<void()> mFinishRequestCallback;
       std::function<void(const Data&)> mReceivedDataCallback;
       std::function<void(std::shared_ptr<Response>)> mReceivedResponseCallback;
       std::function<void(const Error&)> mErrorCallback;
       std::function<void(std::shared_ptr<Request>, std::shared_ptr<Response>)> mRedirectCallback;
       
     public:
       ConnectionProxy(std::shared_ptr<Request> aRequest, const std::string& aCurrentProtocolName);
       ~ConnectionProxy();
       void start();
       void setCallbacks(std::function<void()>, std::function<void(Data)>, std::function<void(std::shared_ptr<Response>)>, std::function<void(Error)>,
                         std::function<void(std::shared_ptr<Request>, std::shared_ptr<Response>)>);
       
       //delegate
       virtual void connectionDidReceiveResponse(std::shared_ptr<Connection> aConnection, std::shared_ptr<Response> aResponse);
       virtual void connectionDidReceiveData(std::shared_ptr<Connection> aConnection, Data aData);
       virtual void connectionDidFinish(std::shared_ptr<Connection> aConnection);
       virtual void connectionDidFailWithError(std::shared_ptr<Connection> aConnection, Error aError);
       virtual void connectionWasRedirected(std::shared_ptr<Connection> aConnection, std::shared_ptr<Request> aRequest, std::shared_ptr<Response> aResponse);
   };
}

#endif /* ConnectionProxy_hpp */
