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
            
            //stub
            NSString* json = @"{\"app_name\": \"RevClient\",\
            \"os\" : \"ios\",\
            \"configs\" : {\
            \"sdk_release_version\" : 1.0,\
            \"configuration_api_url\" : \"https://rev-200.revdn.net\",\
            \"configuration_refresh_interval_sec\" : 10,\
            \"configuration_stale_timeout_sec\" : 100,\
            \"edge_host\" : \"revdn.net\",\
            \"operation_mode\" : 2,\
            \"allowed_transport_protocols\" : [\"standard\"],\
            \"initial_transport_protocol\" : \"standard\",\
            \"transport_monitoring_url\" : \"https://rev-200.revdn.net\",\
            \"stats_reporting_url\" : \"https://rev-200.revdn.net\",\
            \"stats_reporting_interval_sec\" : 10,\
            \"stats_reporting_level\" : 2,\
            \"stats_reporting_max_request_per_report\" : 1,\
            \"domains_provisioned_list\" : [],\
            \"domains_white_list\" : [\"mbeans.com\", \"edition.cnn.com\", \"httpbin.org\"],\
            \"domains_black_list\" : [] }}";
            
            NSData* jsonData  = [json dataUsingEncoding:NSUTF8StringEncoding];
            Data data         = dataFromNSData(jsonData);
            Error error       = Error::notError();
            Response response = *(responseFromHTTPURLResponse((NSHTTPURLResponse *)aResponse).get());
            
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
                                                                                      method:@"POST"
                                                                                        body:body
                                                                           completionHandler:completionHandler];
        [operationQueue addOperation:requestOperation];
    }
}