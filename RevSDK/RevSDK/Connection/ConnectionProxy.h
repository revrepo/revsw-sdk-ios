//
//  ConnectionProxy.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

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
       
       std::function<void()> mFinishRequestCallback;
       std::function<void(Data)> mReceivedDataCallback;
       std::function<void(std::shared_ptr<Response>)> mReceivedResponseCallback;
       std::function<void(Error)> mErrorCallback;
       
     public:
       ConnectionProxy(NSURLRequest* aRequest);
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
