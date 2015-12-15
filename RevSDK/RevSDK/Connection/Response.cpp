//
//  Response.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Response.hpp"

namespace rs
{
    Response::Response(const std::string& aURL,
                       const std::map<std::string, std::string>& aHeaderFields,
                       unsigned long aStatusCode):
    mURL(aURL),
    mHeaderFields(aHeaderFields),
    mStatusCode(aStatusCode)
    {
        
    }
}