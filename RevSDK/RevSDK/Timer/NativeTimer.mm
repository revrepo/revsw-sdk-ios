//
//  NativeTimer.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <Foundation/Foundation.h>

#include "NativeTimer.h"

namespace rs
{
    NativeTimer::NativeTimer(float aInterval, std::function<void()> aFunction)
    {
        mInterval = aInterval;
        mFunction = aFunction;
        
        NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
            
                                        if (aFunction)
                                        {
                                           aFunction();
                                        }
            
                                       }];
        
        timer = ( void *)CFBridgingRetain([NSTimer timerWithTimeInterval:aInterval
                                                                  target:operation
                                                                selector:@selector(main)
                                                                userInfo:nil
                                                                 repeats:YES]);
    }
    
    NativeTimer::~NativeTimer()
    {
        invalidate();
        CFBridgingRelease(timer);
    }
    
    void NativeTimer::start()
    {
        [[NSRunLoop mainRunLoop] addTimer:(__bridge NSTimer *)timer forMode:NSDefaultRunLoopMode];
    }
    
    void NativeTimer::invalidate()
    {
        if (isValid())
        {
           [(__bridge NSTimer *)timer invalidate];
        }
    }
    
    bool NativeTimer::isValid()const
    {
        return [(__bridge NSTimer *)timer isValid];
    }
}
