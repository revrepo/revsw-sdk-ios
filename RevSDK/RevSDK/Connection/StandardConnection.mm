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

namespace rs
{
    void StandardConnection::startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate, std::shared_ptr<Connection> aConnection)
    {
        NSURLRequest* request                             = URLRequestFromRequest(aRequest);
        NSMutableURLRequest* mutableRequest               = request.mutableCopy;
        NSURLSessionConfiguration* sessionConfiguration   = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        [NSURLProtocol setProperty:@YES forKey:kRSURLProtocolHandledKey inRequest:mutableRequest];
        
        const NSString* proxyHost = kRSProxyHostName;
        NSNumber* proxyPort       = [NSNumber numberWithInt: kRSProxyPortNumber];
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
                                               
                                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)aResponse;
                                                
                                                if (!aError)
                                                {
                                                    Data data                          = dataFromNSData(aData);
                                                    std::shared_ptr<Response> response = responseFromHTTPURLResponse(httpResponse);
                                                    
                                                    aDelegate->connectionDidReceiveResponse(aConnection, response);
                                                    aDelegate->connectionDidReceiveData(aConnection, data);
                                                    aDelegate->connectionDidFinish(aConnection);
                                                }
                                                else
                                                {
                                                    Error error = errorFromNSError(aError);
                                                    aDelegate->connectionDidFailWithError(aConnection, error);
                                                }
                                            }];
        [task resume];
    }
}