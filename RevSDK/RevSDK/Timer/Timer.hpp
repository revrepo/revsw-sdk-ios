//
//  Timer.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Timer_hpp
#define Timer_hpp

#include <stdio.h>
#include <iostream>

namespace rs
{
    class NativeTimer;
    
    class Timer
    {
        NativeTimer* timer;
        
        public:
        
        Timer(float, std::function<void()>);
        ~Timer();
        
        void start();
        void invalidate();
        
        bool isValid()const;
    };
}

#endif /* Timer_hpp */
