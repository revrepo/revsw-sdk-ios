//
//  RSNativeNetwork.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef NativeNetwork_h
#define NativeNetwork_h

#include <iostream>

#include <memory>
#include "Request.hpp"

namespace rs
{
    class Data;
    class Response;
    class Error;
    class Protocol;
    
    class NativeNetwork
    {
      public:
          void performRequest(std::string aURL, std::function<void(const Data&, const Response&, const Error&)> aCompletionBlock);
          void performRequest(std::string aURL, const Data& aBody, std::function<void(const Data&, const Response&, const Error&)> aCompletionBlock);
        
        std::shared_ptr<Request> testRequestByURL(const std::string& aURL, Protocol* aConnection, bool aProcess = true);
    };
}
#endif