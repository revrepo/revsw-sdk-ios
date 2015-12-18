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

#include "Data.hpp"

namespace rs
{
   class Request
   {
       std::string mMethod;
       std::string mURL;
       std::map<std::string, std::string> mHeaders;
       Data mBody;
       
   public:
       
       Request(const std::string& aURL, const std::map<std::string, std::string>& aHeaders, const std::string& aMethod, const Data& aBody);
       ~Request(){ printf("Request destructor called\n");}
       
       std::string method() const { return mMethod; }
       std::string URL() const { return mURL; }
       std::map<std::string, std::string> headers() const { return mHeaders; }
       Data body() const { return mBody; }
   };
}

#endif /* Request_hpp */
