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
        NSURLRequest* request                             = URLRequestFromRequest(aRequest);
        NSMutableURLRequest* mutableRequest               = request.mutableCopy;
        NSURLSessionConfiguration* sessionConfiguration   = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSString* proxyHost = @"52.88.151.82";
        NSNumber* proxyPort = [NSNumber numberWithInt: 8080];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSDictionary *proxyDict = @{
                                    @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPProxyHost  : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPProxyPort  : proxyPort,
                                    
                                    @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                    (NSString *)kCFStreamPropertyHTTPSProxyHost : proxyHost,
                                    (NSString *)kCFStreamPropertyHTTPSProxyPort : proxyPort,
                                    };
#pragma clang diagnostic pop
        sessionConfiguration.connectionProxyDictionary = proxyDict;
        
        NSURLSession* session                             = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        
        NSURLSessionTask* task = [session dataTaskWithRequest:mutableRequest
                                            completionHandler:^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
                                            
                                                NSLog(@"Response %@ error %@", aResponse, aError);
                                                
                                                Data data                          = dataFromNSData(aData);
                                                std::shared_ptr<Response> response = responseFromHTTPURLResponse((NSHTTPURLResponse *)aResponse);
                                                
                                                aDelegate->connectionDidReceiveData(aConnection, data);
                                                aDelegate->connectionDidReceiveResponse(aConnection, response);
                                                aDelegate->connectionDidFinish(aConnection);
                                                
                                            }];
        [task resume];
    }
}