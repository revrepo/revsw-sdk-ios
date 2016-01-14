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

#include "LeakDetector.h"

namespace rs
{
    struct Error
    {
        REV_LEAK_DETECTOR(Error);
        
        Error();
        
        void setDescription(std::string aDescription);
        long code;
        std::string domain;
        std::map<std::string, std::string> userInfo;
        
        std::string description()const;
        
        static Error notError();
        
        bool isNoError() const;
    };
}

#endif /* Error_hpp */
