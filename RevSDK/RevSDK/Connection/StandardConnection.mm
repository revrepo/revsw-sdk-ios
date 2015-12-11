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
        
      //  NSLog(@"Request %p headers %@", mutableRequest, mutableRequest.allHTTPHeaderFields);
        
        //NSLog(@"CONNECTION %@", mutableRequest.URL);
        
        NSURLSessionTask* task = [session dataTaskWithRequest:mutableRequest
                                            completionHandler:^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
                                                
                                                std::shared_ptr<Connection> anchor = oAnchor;

                                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)aResponse;
                                                
                                                if (httpResponse.statusCode != 200)
                                                {
                                                    //NSLog(@"Response %@ current request %p ", httpResponse, request);
                                                }
                                                
                                                NSString* str = [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding];
                                                
                                              //  NSLog(@"%@", str);
                                                
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

//{
//    "args": {},
//    "headers": {
//        "Accept": "*/*",
//        "Accept-Encoding": "gzip, deflate",
//        "Accept-Language": "en-us",
//        "Host": "httpbin.org",
//        "User-Agent": "RevTest%20App/1.0.0 CFNetwork/758.1.6 Darwin/15.0.0"
//    },
//    "origin": "193.107.172.208",
//    "url": "https://httpbin.org/get"
//}
//
//{
//    "args": {},
//    "headers": {
//        "Accept": "*/*",
//        "Accept-Encoding": "gzip, deflate",
//        "Accept-Language": "en-us",
//        "Cookie": "NOSTO_SESSION=3d7db7ea6a96e55601a8a8af4828886cd3591da3-___AT=caf3769038821b4d723592c49972e4f15e79a23b&___TS=1449861400957; csrftoken=WBavH1XlHEw4qyKiQWuibnNUxE293diO",
//        "Host": "httpbin.org",
//        "User-Agent": "RevTest%20App/1.0.0 CFNetwork/758.1.6 Darwin/15.0.0",
//        "X-Rev-Host": "httpbin.org"
//    },
//    "origin": "108.61.199.207",
//    "url": "https://httpbin.org/get"
//}
