//
//  StandardConnection.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "StandardConnection.hpp"
#include "RSUtils.h"
#include "RSURLProtocol.h"

namespace rs
{
    void StandardConnection::startWithRequest(std::shared_ptr<Request> aRequest)
    {
        NSURLRequest* request = URLRequestFromRequest(aRequest);
        
        NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.protocolClasses = @[[RSURLProtocol class]];
        
    }
}