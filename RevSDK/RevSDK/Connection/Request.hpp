//
//  Request.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Request_hpp
#define Request_hpp

#include <stdio.h>
#include <iostream>
#include <string>
#include <map>

#include "LeakDetector.h"
#include "Data.hpp"

namespace rs
{
   class Request
   {
       REV_LEAK_DETECTOR(Request);

       std::string mMethod;
       std::string mOriginalURL;
       std::string mURL;
       std::map<std::string, std::string> mHeaders;
       Data mBody;
       std::string mHost;
       std::string mPath;
       std::string mRest;
       std::string mOriginalScheme;
       
   public:
       
       Request(const std::string& aURL, const std::map<std::string, std::string>& aHeaders, const std::string& aMethod, const Data& aBody);
       Request() = delete;
       ~Request(){ /*printf("Request destructor called\n");*/ }
       
       std::string method() const { return mMethod; }
       std::string URL() const { return mURL; }
       std::map<std::string, std::string> headers() const { return mHeaders; }
       Data body() const { return mBody; }
       
       std::string host() const { return mHost; }
       std::string path() const { return mPath; }
       std::string rest() const { return mRest; }
       std::string originalScheme() const { return mOriginalScheme; }
       std::string originalURL() const { return mOriginalURL; }
       
       void setHost(const std::string& aHost) { mHost = aHost; }
       void setPath(const std::string& aPath) { mPath = aPath; }
       void setRest(const std::string& aRest) { mRest = aRest; }
       void setOriginalScheme(const std::string& aOriginalScheme) { mOriginalScheme = aOriginalScheme; }
       void setMethod(const std::string& aMethod) { mMethod = aMethod; }
       void setURL(const std::string& aURL) { mURL = aURL; }
       void setHeaders(const std::map<std::string, std::string>& aHeaders) { mHeaders = aHeaders; }
       void setOriginalURL(const std::string& aOriginalURL) { mOriginalURL = aOriginalURL; }
       
       
       Request* clone() const;
   };
}

#endif /* Request_hpp */
