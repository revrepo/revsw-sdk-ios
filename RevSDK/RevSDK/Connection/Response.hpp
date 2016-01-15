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

#ifndef Response_hpp
#define Response_hpp

#include "Data.hpp"

#include <stdio.h>
#include <iostream>
#include <string>
#include <map>

namespace rs
{
    class Response
    {
    private:
        std::string mURL;
        std::map<std::string, std::string> mHeaderFields;
        unsigned long mStatusCode;
        Data mBody;
    public:

        Response(const std::string& aURL, const std::map<std::string, std::string>& aHeaderFields, unsigned long aStatusCode);
        const std::string& URL() const { return mURL; }
        const std::map<std::string, std::string>& headerFields() const { return mHeaderFields; }
        unsigned long statusCode() const { return mStatusCode; }
        
        void setBody(const Data& aBody) { mBody = aBody; }
        
        const Data& body() const { return mBody; }
    };
}

#endif /* Response_hpp */
