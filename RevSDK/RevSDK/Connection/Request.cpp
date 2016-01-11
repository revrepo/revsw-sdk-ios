//
//  Request.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

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