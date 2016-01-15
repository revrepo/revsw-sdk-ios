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

#include "Error.hpp"
#include "Utils.hpp"

namespace rs
{
    Error::Error():
        code(noErrorCode())
    {
        noErrorCode();
    }

    void Error::setDescription(std::string aDescription)
    {
        std::string key = errorDescriptionKey();
        userInfo[key] = aDescription;
    }
    
    std::string Error::description() const
    {
        std::string key                       = errorDescriptionKey();
        std::map<std::string, std::string>::const_iterator w = userInfo.find(key);
        if (w == userInfo.end())
            return "";
        return w->second;
    }
    
    Error Error::notError()
    {
        Error error;
        error.code = noErrorCode();
        return error;
    }
    
    bool Error::isNoError()const
    {
        return code == noErrorCode();
    }
}
