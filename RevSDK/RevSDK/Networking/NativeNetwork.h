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

#ifndef NativeNetwork_h
#define NativeNetwork_h

#include <iostream>

#include <memory>
#include "Request.hpp"

namespace rs
{
    class Data;
    class Response;
    class Error;
    class Protocol;
    
    class NativeNetwork
    {
      public:
          void performRequest(std::string aURL, std::function<void(const Data&, const Response&, const Error&)> aCompletionBlock);
          void performRequest(std::string aURL, const Data& aBody, std::function<void(const Data&, const Response&, const Error&)> aCompletionBlock);
        
        std::shared_ptr<Request> testRequestByURL(const std::string& aURL, Protocol* aConnection, bool aProcess = true);
    };
}
#endif