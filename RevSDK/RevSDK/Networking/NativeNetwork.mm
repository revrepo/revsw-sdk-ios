/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

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
            
            NSString* edgeHostString = NSStringFromStdString(Model::instance()->edgeHost());
            
            const BOOL usingRevHost =
            [aResponse.URL.host isEqualToString:edgeHostString] ||
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
            
            NSString* edgeHostString = NSStringFromStdString(Model::instance()->edgeHost());
            
            const BOOL usingRevHost =
            [aResponse.URL.host isEqualToString:edgeHostString] ||
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
        
        NSMutableURLRequest* mutableReq = [req mutableCopy];
        
        [NSURLProtocol setProperty:@YES forKey:kRSURLProtocolHandledKey inRequest:mutableReq];
        
        if (aProcess)
        {
            bool flag = aProto->protocolName() == standardProtocolName();
            req = [RSURLRequestProcessor proccessRequest:mutableReq isEdge:flag baseURL:nil];
        }
        else
        {
            req = mutableReq;
        }
        
        auto request = requestFromURLRequest(req);
        request->setOriginalScheme(rs::stdStringFromNSString(req.URL.scheme));
        
        std::string lg = rs::stdStringFromNSString([[req allHTTPHeaderFields] description]);
        
        Log::info(rs::kLogTagSDKLastMile, ("All http heades of request:: " + lg).c_str());
        
        return request;
    }
}















