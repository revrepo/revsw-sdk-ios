//
//  NativeTimer.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <Foundation/Foundation.h>

#include "Timer.hpp"

namespace rs
{
    Timer::Timer(float aInterval, std::function<void()> aFunction)
    {
        mInterval = aInterval;
        mFunction = aFunction;
        
        NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
            
                                        if (aFunction)
                                        {
                                           aFunction();
                                        }
            
                                       }];
        
        mTimer = ( void *)CFBridgingRetain([NSTimer timerWithTimeInterval:aInterval
                                                                   target:operation
                                                                 selector:@selector(main)
                                                                 userInfo:nil
                                                                  repeats:YES]);
    }
    
    //static
    void Timer::scheduleTimer(std::unique_ptr<Timer>& aTimer, int aInterval, std::function<void()> aFunction)
    {
        if (aInterval > 0)
        {
            aTimer = std::unique_ptr<Timer>(new Timer(aInterval, aFunction));
            aTimer->start();
        }
    }
    //static
    void Timer::disableTimer(std::unique_ptr<Timer>& aTimer)
    {
        if (aTimer)
        {
            aTimer->invalidate();
            //delete aTimer;
            aTimer = nullptr;
        }
    }
    
    Timer::~Timer()
    {
        invalidate();
        CFBridgingRelease(mTimer);
    }
    
    void Timer::start()
    {
        [[NSRunLoop mainRunLoop] addTimer:(__bridge NSTimer *)mTimer forMode:NSDefaultRunLoopMode];
    }
    
    void Timer::invalidate()
    {
        if (isValid())
        {
           [(__bridge NSTimer *)mTimer invalidate];
        }
    }
    
    bool Timer::isValid()const
    {
        return [(__bridge NSTimer *)mTimer isValid];
    }
}
