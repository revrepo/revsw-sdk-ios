//
//  NativeTimer.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef NativeTimer_hpp
#define NativeTimer_hpp

#include <stdio.h>
#include <iostream>

namespace rs
{
    class NativeTimer
    {
        void* timer;
        float mInterval;
        std::function<void()> mFunction;
        
        public:
        
        NativeTimer(float, std::function<void()>);
        ~NativeTimer();
        
        void start();
        void invalidate();
        
        bool isValid()const;
    };
}

#endif /* NativeTimer_hpp */
