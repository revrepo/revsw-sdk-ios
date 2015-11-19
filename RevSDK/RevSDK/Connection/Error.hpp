//
//  Error.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Error_hpp
#define Error_hpp

#include <stdio.h>
#include <iostream>

#include <string>
#include <map>

namespace rs
{
    struct Error
    {
        long code;
        std::string domain;
        std::map<std::string, std::string> userInfo;
    };
}

#endif /* Error_hpp */
