//
//  Connection.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Connection_hpp
#define Connection_hpp

#include <stdio.h>
#include <iostream>

namespace rs
{
    class Request;
    class Connection;
    class Response;
    class Data;
    class Error;
    
    class ConnectionDelegate
    {
    public:
        
        virtual void connectionDidReceiveResponse(std::shared_ptr<Connection> aConnection, std::shared_ptr<Response> aResponse) = 0;
        virtual void connectionDidReceiveData(std::shared_ptr<Connection> aConnection, Data aData) = 0;
        virtual void connectionDidFinish(std::shared_ptr<Connection> aConnection) = 0;
        virtual void connectionDidFailWithError(std::shared_ptr<Connection> aConnection, Error aError) = 0;
    };
    
    class Connection
    {
    public:
        virtual void startWithRequest(std::shared_ptr<Request>, ConnectionDelegate*) = 0;
        template <class T>
        static std::shared_ptr<Connection> create()
        {
            std::shared_ptr<Connection> result(new T());
            result->mWeakThis = std::weak_ptr<Connection>(result);
            return result;
        }
    protected:
        std::weak_ptr<Connection> mWeakThis;
    };
}

#endif /* Connection_hpp */
