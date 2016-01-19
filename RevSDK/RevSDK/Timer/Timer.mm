/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

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
    
    float Timer::interval()const
    {
        return mInterval;
    }
}
