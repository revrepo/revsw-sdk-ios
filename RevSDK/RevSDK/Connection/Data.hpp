//
//  Data.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Data_hpp
#define Data_hpp

#include <stdio.h>
#include <string>

namespace rs
{
    struct Data
    {
        void* bytes;
        unsigned long length;
        
        std::string toString();
    };
}

#endif /* Data_hpp */
