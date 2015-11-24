//
//  Timer.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Timer.hpp"
#include "NativeTimer.h"

namespace rs
{
    Timer::Timer(float aInterval, std::function<void()> aFunction)
    {
        timer = new NativeTimer(aInterval, aFunction);
    }
    
    Timer::~Timer()
    {
        delete timer;
    }
    
    void Timer::start()
    {
        timer->start();
    }
    
    void Timer::invalidate()
    {
        timer->invalidate();
    }
    
    bool Timer::isValid()const
    {
        return timer->isValid();
    }
}