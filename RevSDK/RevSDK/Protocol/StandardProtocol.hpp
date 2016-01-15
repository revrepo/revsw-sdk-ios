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

#ifndef StandardProtocol_hpp
#define StandardProtocol_hpp

#include <stdio.h>

#include "Protocol.hpp"

namespace rs
{
    class StandardProtocol : public Protocol
    {
    public:
        std::shared_ptr<Protocol> clone() { return std::make_shared<StandardProtocol>(); }
        
        std::string protocolName(); 
    };
}

#endif /* StandardProtocol_hpp */
