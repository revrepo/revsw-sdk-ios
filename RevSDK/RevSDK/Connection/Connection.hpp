//
//  Connection.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Connection_hpp
#define Connection_hpp

#include <stdio.h>

namespace rs
{
    class Connection
    {
    public:
       virtual void start() = 0;
    };
}

#endif /* Connection_hpp */
