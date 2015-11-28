//
//  Request.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Request.hpp"

namespace rs
{
    Request::Request(std::string aURL, std::map<std::string, std::string> aHeaders, std::string aMethod, Data aBody): mURL(aURL), mHeaders(aHeaders), mMethod(aMethod), mBody(aBody)
    {
        
    }
}