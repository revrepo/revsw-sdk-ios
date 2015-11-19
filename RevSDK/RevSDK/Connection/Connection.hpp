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
    
    class ConnectionDelegate
    {
    public:
        
        virtual void connectionDidReceiveResponse(std::shared_ptr<Connection> aConnection, std::shared_ptr<Response> aResponse) = 0;
        virtual void connectionDidReceiveData(std::shared_ptr<Connection> aConnection, Data aData) = 0;
        virtual void connectionDidFinish(std::shared_ptr<Connection> aConnection) = 0;
    };
    
    class Connection
    {
    public:
        virtual void startWithRequest(std::shared_ptr<Request>, ConnectionDelegate*, std::shared_ptr<Connection>) = 0;
    };
}

#endif /* Connection_hpp */
