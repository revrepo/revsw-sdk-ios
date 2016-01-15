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

#ifndef Event_hpp
#define Event_hpp

#include <stdio.h>
#include <string>
#include <chrono>
#include <ctime>
#include "LeakDetector.h"

namespace rs
{
    struct Event
    {
        REV_LEAK_DETECTOR(Event);
        
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
