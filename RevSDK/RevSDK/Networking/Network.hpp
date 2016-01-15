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

#ifndef Network_hpp
#define Network_hpp

#include <stdio.h>
#include <iostream>

namespace rs
{
    class Data;
    class Error;
    class NativeNetwork;
    class Protocol;
    class ConnectionDelegate;
    
    class Network
    {
    private:
        static NativeNetwork* mNativeNetwork;
        
        void performRequest(std::string aURL, std::function<void(const Data&, const Error&)> aCompletionBlock);
        void performRequest(std::string aURL, const Data& aBody, std::function<void(const Data&, const Error&)> aCompletionBlock);
        
    public:
        
        Network();
        ~Network();
        
        void loadConfiguration(const std::string&, std::function<void(const Data&, const Error&)> aCompletionBlock);
        
        void sendStats(std::string aURL, const Data&, std::function<void(const Error&)>);
        
        void performReques(std::shared_ptr<Protocol> aProtocol, std::string aURL, ConnectionDelegate* aDelegate);
    };
}

#endif /* Network_hpp */
