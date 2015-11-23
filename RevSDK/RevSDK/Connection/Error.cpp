//
//  Error.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Error.hpp"

namespace rs
{
    std::string Error::description()
    {
        std::string key = errorDescriptionKey();
        return userInfo[key];
    }
}
