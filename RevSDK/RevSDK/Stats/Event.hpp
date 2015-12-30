//
//  Event.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Event_hpp
#define Event_hpp

#include <stdio.h>
#include <string>
#include <chrono>
#include <ctime>

namespace rs
{
    struct Event
    {
        std::string severity;
        int code;
        std::string message;
        float interval;
        long double timestamp;
        
        Event(){}
        Event(const std::string& aSeverity, const int& aCode, const std::string& aMessage, const float& aInterval) : severity(aSeverity),
        code(aCode),
        message(aMessage),
        interval(aInterval)
        {
            long double milliseconds_since_epoch = std::chrono::system_clock::now().time_since_epoch() / std::chrono::milliseconds(1);
            timestamp = milliseconds_since_epoch;
        }
        
    };
}

#endif /* Event_hpp */
