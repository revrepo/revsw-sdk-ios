
//
//  RSNativeNetwork.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "NativeNetwork.h"
#include "RSURLRequestProcessor.h"
#include "RSRequestOperation.h"
#include "Data.hpp"
#include "Response.hpp"
#include "Error.hpp"
#include "RSUtils.h"
#include "Model.hpp"
#include "DebugUsageTracker.hpp"

namespace rs
{
    static NSOperationQueue* operationQueue = [NSOperationQueue new];
    
    void NativeNetwork::performRequest(std::string aURL, std::function<void(const Data&, const Response&, const Error&)> aCompletionBlock)
    {
        void (^completionHandler)(NSData*, NSURLResponse*, NSError*) = ^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
            
            Data data         = dataFromNSData(aData);
            Response response = *(responseFromHTTPURLResponse((NSHTTPURLResponse *)aResponse));
            Error error       = errorFromNSError(aError);
            
            // Debug:
            const BOOL usingRevHost =
            [aResponse.URL.host isEqualToString:kRSRevRedirectHost] ||
            [aResponse.URL.host isEqualToString:kRSRevLoadConfigurationHost];
            Model::instance()->debug_usageTracker()->trackRequest(usingRevHost, data.length(), response, error);
            
            aCompletionBlock(data, response, error);
        };
        
        RSRequestOperation* requestOperation = [[RSRequestOperation alloc] initWithURLString:NSStringFromStdString(aURL)
                                                                                      method:@"GET"
                                                                                        body:nil
                                                                           completionHandler:completionHandler];
        [operationQueue addOperation:requestOperation];
    }
    
    void NativeNetwork::performRequest(std::string aURL, const Data& aBody, std::function<void(const Data&, const Response&, const Error&)> aCompletionBlock)
    {
        void (^completionHandler)(NSData*, NSURLResponse*, NSError*) = ^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
            
            Data data         = dataFromNSData(aData);
            Error error       = errorFromNSError(aError);
            Response response = *(responseFromHTTPURLResponse((NSHTTPURLResponse *)aResponse).get());
            
            // Debug:
            const BOOL usingRevHost =
            [aResponse.URL.host isEqualToString:kRSRevRedirectHost] ||
            [aResponse.URL.host isEqualToString:kRSRevLoadConfigurationHost];
            Model::instance()->debug_usageTracker()->trackRequest(usingRevHost, data.length(), response, error);
            
            aCompletionBlock(data, response, error);
        };
        
        NSData* body = NSDataFromData(aBody);
        RSRequestOperation* requestOperation = [[RSRequestOperation alloc] initWithURLString:NSStringFromStdString(aURL)
                                                                                      method:@"PUT"
                                                                                        body:body
                                                                           completionHandler:completionHandler];
        [operationQueue addOperation:requestOperation];
    }
    
    std::shared_ptr<Request> NativeNetwork::testRequestByURL(const std::string& aURL, Protocol* aProto, bool aProcess /*=true*/)
    {
        NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:NSStringFromStdString(aURL)]];
        
        NSMutableURLRequest* mreq = [req mutableCopy];
        
        [NSURLProtocol setProperty:@YES forKey:kRSURLProtocolHandledKey inRequest:mreq];
        
        if (aProcess)
        {
            bool flag = aProto->protocolName() == standardProtocolName();
            req = [RSURLRequestProcessor proccessRequest:mreq isEdge:flag];
        }
        
        auto request = requestFromURLRequest(mreq);
        request->setOriginalScheme(rs::stdStringFromNSString(req.URL.scheme));
        
        return request;
    }
}















