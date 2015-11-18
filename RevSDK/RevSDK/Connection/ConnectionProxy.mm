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
#include "Connection.hpp"
#include "Model.hpp"

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
        connection.get()->startWithRequest(mRequest);
    }
}