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

#include "Request.hpp"

namespace rs
{
    Request::Request(const std::string& aURL, const std::map<std::string, std::string>& aHeaders, const std::string& aMethod, const Data& aBody): mURL(aURL), mHeaders(aHeaders), mMethod(aMethod), mBody(aBody)
    {
        mOriginalURL = mURL;
    }
    
    Request* Request::clone() const
    {
        Request* res = new Request(mURL, mHeaders, mMethod, mBody.clone());
        res->setHost(mHost);
        res->setPath(mPath);
        res->setRest(mRest);
        res->setOriginalScheme(mOriginalScheme);
        res->setOriginalURL(mOriginalURL);
        return res;
    }
}