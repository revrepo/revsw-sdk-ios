//
//  RVURLConnection.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <stdio.h>
#import <memory>

#import "RSUtils.h"
#import "RSURLConnection.h"
#import "RSURLRequestProcessor.h"

#import "ConnectionProxy.h"
#import "Data.hpp"
#import "Response.hpp"
#import "Error.hpp"
#import "Model.hpp"

@interface RSURLConnection ()
{
    std::shared_ptr<rs::ConnectionProxy> connectionProxy;
}

@end

@implementation RSURLConnection

+ (nullable instancetype)connectionWithRequest:(NSURLRequest *)aRequest delegate:(id<RSURLConnectionDelegate>)aDelegate
{
    RSURLConnection* connection = [[RSURLConnection alloc] initWithRequest:aRequest delegate:aDelegate];
    
    return connection;
}

- (instancetype)initWithRequest:(NSURLRequest *)aRequest delegate:(nullable id<RSURLConnectionDelegate>)aDelegate
{
    self = [super init];
    
    if (self)
    {
        self.delegate = aDelegate;
        
        std::function<void()> finishCallback = [self](){
        
            [self.delegate rs_connectionDidFinishLoading:self];
        };
        
        std::function<void(rs::Data)> dataCallback = [self](rs::Data aData){
           
            NSData* data = rs::NSDataFromData(aData);
            [self.delegate rs_connection:self didReceiveData:data];
        };
        
        std::function<void(std::shared_ptr<rs::Response>)> responseCallback = [self](std::shared_ptr<rs::Response> aResponse){
            
            NSHTTPURLResponse* response = rs::NSHTTPURLResponseFromResponse(aResponse);
            [self.delegate rs_connection:self didReceiveResponse:response];
        };
        
        std::function<void(rs::Error)> errorCallback = [self](rs::Error aError){
        
            NSError* error = rs::NSErrorFromError(aError);
            [self.delegate rs_connection:self didFailWithError:error];
        };
        
        BOOL testPassOptionOn    = rs::Model::instance()->testPassOption();
        NSURLRequest* newRequest = (aRequest.URL.host || testPassOptionOn) ? [RSURLRequestProcessor proccessRequest:aRequest] : aRequest;
        connectionProxy          = std::make_shared<rs::ConnectionProxy>(rs::requestFromURLRequest(newRequest));
        connectionProxy.get()->setCallbacks(finishCallback, dataCallback, responseCallback, errorCallback);
    }
    
    return self;
}

- (void)start
{
    connectionProxy.get()->start();
}

@end
