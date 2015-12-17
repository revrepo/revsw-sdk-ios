//
//  Error.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Error.hpp"
#include "RSUtilsBridge.hpp"

namespace rs
{
    std::string Error::description() const
    {
        std::string key                       = errorDescriptionKey();
        std::map<std::string, std::string> ui = userInfo;
        std::string description               = ui[key];
        return description;
    }
    
    Error Error::notError()
    {
        Error error;
        error.code = noErrorCode();
        return error;
    }
    
    bool Error::isNoError()const
    {
        return code == noErrorCode();
    }
}
