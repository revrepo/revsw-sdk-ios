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
        StandardConnection(const StandardConnection &aConnection) = delete;
        StandardConnection();
        ~StandardConnection();
        
        void startWithRequest(std::shared_ptr<Request>, ConnectionDelegate*);
        
        std::string edgeTransport()const;
    private: 
    };
}

#endif /* StandardConnection_hpp */
