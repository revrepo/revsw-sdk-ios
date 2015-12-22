
//
//  RSNativeNetwork.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "NativeNetwork.h"
#include "RSRequestOperation.h"
#include "Data.hpp"
#include "Response.hpp"
#include "Error.hpp"
#include "RSUtils.h"

namespace rs
{
    static NSOperationQueue* operationQueue = [NSOperationQueue new];
    
    void NativeNetwork::performRequest(std::string aURL, std::function<void(const Data&, const Response&, const Error&)> aCompletionBlock)
    {
        void (^completionHandler)(NSData*, NSURLResponse*, NSError*) = ^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
            
            Data data         = dataFromNSData(aData);
            Response response = *(responseFromHTTPURLResponse((NSHTTPURLResponse *)aResponse));
            Error error       = errorFromNSError(aError);
            
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
            
            aCompletionBlock(data, response, error);
        };
        
        NSData* body = NSDataFromData(aBody);
        RSRequestOperation* requestOperation = [[RSRequestOperation alloc] initWithURLString:NSStringFromStdString(aURL)
                                                                                      method:@"PUT"
                                                                                        body:body
                                                                           completionHandler:completionHandler];
        [operationQueue addOperation:requestOperation];
    }
}