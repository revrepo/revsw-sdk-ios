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

#ifndef Error_hpp
#define Error_hpp

#include <stdio.h>
#include <iostream>

#include <string>
#include <map>

#include "LeakDetector.h"

namespace rs
{
    struct Error
    {
        REV_LEAK_DETECTOR(Error);
        
        Error();
        
        void setDescription(std::string aDescription);
        long code;
        std::string domain;
        std::map<std::string, std::string> userInfo;
        
        std::string description()const;
        
        static Error notError();
        
        bool isNoError() const;
    };
}

#endif /* Error_hpp */
