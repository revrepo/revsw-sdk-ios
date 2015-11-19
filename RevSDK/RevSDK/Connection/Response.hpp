//
//  Response.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Response_hpp
#define Response_hpp

#include <stdio.h>
#include <iostream>
#include <string>
#include <map>

namespace rs
{
    class Response
    {
        std::string mURL;
        std::map<std::string, std::string> mHeaderFields;
        unsigned long mStatusCode;
        
    public:
        
        Response(std::string aURL, std::map<std::string, std::string> aHeaderFields, unsigned long aStatusCode);
        
        std::string URL() const{ return mURL;}
        std::map<std::string, std::string> headerFields() const { return mHeaderFields;}
        unsigned long statusCode() const { return mStatusCode;}
    };
}

#endif /* Response_hpp */
