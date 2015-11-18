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

namespace rs
{

   class Request;
    
   class ConnectionProxy
   {
       std::shared_ptr<Request> mRequest;
       
     public:
       ConnectionProxy(NSURLRequest* aRequest);
       ~ConnectionProxy();
       
       void start();
   };
}

#endif /* ConnectionProxy_hpp */
