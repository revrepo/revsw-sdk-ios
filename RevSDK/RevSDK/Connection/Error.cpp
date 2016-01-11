//
//  Error.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Error.hpp"
#include "Utils.hpp"

namespace rs
{
    Error::Error():
        code(noErrorCode())
    {
        noErrorCode();
    }

    void Error::setDescription(std::string aDescription)
    {
        std::string key = errorDescriptionKey();
        userInfo[key] = aDescription;
    }
    
    std::string Error::description() const
    {
        std::string key                       = errorDescriptionKey();
        std::map<std::string, std::string>::const_iterator w = userInfo.find(key);
        if (w == userInfo.end())
            return "";
        return w->second;
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
