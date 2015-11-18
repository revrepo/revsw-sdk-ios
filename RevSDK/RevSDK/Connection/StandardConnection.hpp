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
       public:
        void startWithRequest(std::shared_ptr<Request>);
    };
}

#endif /* StandardConnection_hpp */
