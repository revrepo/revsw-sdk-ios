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

#ifndef Protocol_hpp
#define Protocol_hpp

#include <stdio.h>
#include <string>

#include <memory>
#include "LeakDetector.h"

namespace rs
{
    class Protocol
    {
        REV_LEAK_DETECTOR(Protocol);
        
    public:
        virtual std::shared_ptr<Protocol> clone() = 0;
        
        virtual std::string protocolName() = 0;
    };
}

#endif /* Protocol_hpp */
