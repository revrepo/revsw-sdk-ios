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
#include "Data.hpp"
#include "Response.hpp"
#include "Request.hpp"

namespace rs
{
    void StandardConnection::startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate, std::shared_ptr<Connection> aConnection)
    {
        NSURLRequest* request = URLRequestFromRequest(aRequest);
        NSMutableURLRequest* mutableRequest = request.mutableCopy;
        //[NSURLProtocol setProperty:@YES forKey:rs::kRSURLProtocolHandledKey inRequest:mutableRequest];
        
        NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        
        NSURLSessionTask* task = [session dataTaskWithRequest:mutableRequest
                                            completionHandler:^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
                                            
                                                Data data = dataFromNSData(aData);
                                                
                                                std::shared_ptr<Response> response = responseFromHTTPURLResponse((NSHTTPURLResponse *)aResponse);
                                                NSLog(@"LENGTH %lu", data.length);
                                                aDelegate->connectionDidReceiveData(aConnection, data);
                                                aDelegate->connectionDidReceiveResponse(aConnection, response);
                                                aDelegate->connectionDidFinish(aConnection);
                                                
                                            }];
        [task resume];
    }
}