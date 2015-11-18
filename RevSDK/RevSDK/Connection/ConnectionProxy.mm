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
//#include "RSUtils.h"
#include "Request.hpp"
#include "Connection.hpp"
#include "Model.hpp"

namespace rs
{
    ConnectionProxy::ConnectionProxy(NSURLRequest* aRequest)
    {
  //      mRequest = requestFromURLRequest(aRequest);
        
        std::cout << "Connection Proxy constructor\n";
    }
    
    ConnectionProxy::~ConnectionProxy()
    {
        std::cout << "Connection Proxy destructor\n";
    }
    
    void ConnectionProxy::start()
    {
    
    }
}