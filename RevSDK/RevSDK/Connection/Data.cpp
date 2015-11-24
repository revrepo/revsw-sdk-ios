//
//  Data.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Data.hpp"

namespace rs
{
    std::string Data::toString()
    {
        std::string str = "";
        char* cPtr = (char *)bytes;
        
        for (int i = 0; i < length; i++)
        {
            str += *(cPtr++);
        }
        
        return str;
    }
}