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

namespace rs
{
   class Request
   {
       std::string mURL;
       
   public:
       
       Request(std::string aURL);
       ~Request(){ printf("Request destructor called\n");}
       
       std::string URL(){ return mURL; }
   };
}

#endif /* Request_hpp */
