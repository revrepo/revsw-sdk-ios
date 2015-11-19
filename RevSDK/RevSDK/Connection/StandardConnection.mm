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
    void StandardConnection::startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate)
    {
        NSURLRequest* request                             = URLRequestFromRequest(aRequest);
        NSMutableURLRequest* mutableRequest               = request.mutableCopy;
        NSURLSessionConfiguration* sessionConfiguration   = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSString* targetHost = request.URL.host;
        
        [NSURLProtocol setProperty:@YES forKey:kRSURLProtocolHandledKey inRequest:mutableRequest];
        if (targetHost != nil)
            [mutableRequest addValue:targetHost forHTTPHeaderField:@"Host"];
        //static NSString* const kEdgeHost = @"mbeans.com";
        static NSString* const kEdgeHost = @"rev-200.revdn.net";
        NSString* newURL = request.URL.absoluteString;
        
        std::shared_ptr<Connection> oAnchor = mWeakThis.lock();

        if (targetHost != nil)
        {
            [newURL stringByReplacingOccurrencesOfString:targetHost
                                              withString:kEdgeHost];
        }
        else
        {
            NSLog(@"");
            Error error;
            error.code     = 404;
            error.domain   = "com.revsdk";
            error.userInfo = std::map <std::string, std::string>();
            error.userInfo["description"] = "URL not supported";
            aDelegate->connectionDidFailWithError(oAnchor, error);
            return;
        }
        
        [mutableRequest setURL:[NSURL URLWithString:newURL]];
        
        const NSString* proxyHost = kRSProxyHostName;
        
        int portNumber = kRSProxyPortNumber;
        if ([request.URL.absoluteString rangeOfString:@"https"].location == 0)
            portNumber = 443;
        NSNumber* proxyPort       = [NSNumber numberWithInt:portNumber];
        
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
        //sessionConfiguration.connectionProxyDictionary = proxyDict;
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        

        NSURLSessionTask* task = [session dataTaskWithRequest:mutableRequest
                                            completionHandler:^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
                                                                                           
                                                std::shared_ptr<Connection> anchor = oAnchor;

                                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)aResponse;
                                                
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