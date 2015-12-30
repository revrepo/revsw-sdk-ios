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
    class Timer
    {
        void* mTimer;
        float mInterval;
        std::function<void()> mFunction;
        
    public:
        
        Timer(float, std::function<void()>);
        ~Timer();
        
        static void scheduleTimer(std::unique_ptr<Timer>&, int, std::function<void()>);
        static void disableTimer(std::unique_ptr<Timer>&);
        
        void start();
        void invalidate();
        
        bool isValid()const;
    };
}

#endif /* Timer_hpp */
