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
    Request::Request(std::string aURL): mURL(aURL)
    {
        printf("Request constructor called\n");
    }
}