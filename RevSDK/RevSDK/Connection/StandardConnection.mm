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
#include "Error.hpp"
#include "RSUtilsBridge.hpp"

namespace rs
{
    void StandardConnection::startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate)
    {
        std::shared_ptr<Connection> oAnchor = mWeakThis.lock();
        NSURLRequest* request               = URLRequestFromRequest(aRequest);
        NSMutableURLRequest* mutableRequest = request.mutableCopy;
        NSString* targetHost                = request.URL.host;
        
        if (!targetHost)
        {
            Error error;
            error.code     = 404;
            error.domain   = "com.revsdk";
            error.userInfo = std::map <std::string, std::string>();
            error.userInfo[errorDescriptionKey()] = "URL not supported";
            aDelegate->connectionDidFailWithError(oAnchor, error);
            return;
        }
        
        [NSURLProtocol setProperty:@YES forKey:kRSURLProtocolHandledKey inRequest:mutableRequest];

        NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session                           = [NSURLSession sessionWithConfiguration:sessionConfiguration];

        // It turns out that NSURLSession doesn't support synchronous calls
        // The only solution found on the web is to use semaphores, but it provides only pseudo synchronous behaviour and doesn't resolve the problem
        // Another solution is to use NSURLConnection, but it is deprecated, so I've decided to stick to NSURLSession by now
        
        //NSLog(@"Request %p headers %@", request, request.allHTTPHeaderFields);
        
       // NSLog(@"CONNECTION %@", mutableRequest.URL);
        
        NSURLSessionTask* task = [session dataTaskWithRequest:mutableRequest
                                            completionHandler:^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
       
       
                                               // NSLog(@"String %@", [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding]);
                                                //NSLog(@"Response %@", aResponse);
                                                
                                                std::shared_ptr<Connection> anchor = oAnchor;

                                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)aResponse;
                                                
                                                if (httpResponse.statusCode != 200)
                                                {
                                                    NSLog(@"Response %@ current request %p ", httpResponse, request);
                                                }
                                                
                                                if (!aError)
                                                {
                                                    Data data                          = dataFromNSData(aData);
                                                    std::shared_ptr<Response> response = responseFromHTTPURLResponse(httpResponse);
                                                    
                                                    aDelegate->connectionDidReceiveResponse(anchor, response);
                                                    aDelegate->connectionDidReceiveData(anchor, data);
                                                    aDelegate->connectionDidFinish(anchor);
                                                }
                                                else
                                                {
                                                    Error error = errorFromNSError(aError);
                                                    aDelegate->connectionDidFailWithError(anchor, error);
                                                }
                                            }];
        [task resume];
    }
}