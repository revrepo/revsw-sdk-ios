//
//  StandardConnection.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef StandardConnection_hpp
#define StandardConnection_hpp

#include <stdio.h>

#include "Connection.hpp"

namespace rs
{
    class StandardConnection : public Connection
    {
        void* mSessionDelegate;
       public:
        StandardConnection() : mSessionDelegate(nullptr){}
        StandardConnection(const StandardConnection &aConnection){}
        void startWithRequest(std::shared_ptr<Request>, ConnectionDelegate*);
    };
}

#endif /* StandardConnection_hpp */
