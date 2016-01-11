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
#import "Request.hpp"

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
        
            [self.delegate rsconnectionDidFinishLoading:self];
        };
        
        std::function<void(rs::Data)> dataCallback = [self](rs::Data aData){
           
            NSData* data = rs::NSDataFromData(aData);
            [self.delegate rsconnection:self didReceiveData:data];
        };
        
        std::function<void(std::shared_ptr<rs::Response>)> responseCallback = [self](std::shared_ptr<rs::Response> aResponse){
            
            NSHTTPURLResponse* response = rs::NSHTTPURLResponseFromResponse(aResponse);
            [self.delegate rsconnection:self didReceiveResponse:response];
        };
        
        std::function<void(rs::Error)> errorCallback = [self](rs::Error aError){
        
            NSError* error = rs::NSErrorFromError(aError);
            [self.delegate rsconnection:self didFailWithError:error];
        };
        
        std::string currentProtocolName = rs::Model::instance()->currentProtocol()->protocolName();
        BOOL isEdge = currentProtocolName == rs::standardProtocolName();
        
        NSURLRequest* newRequest             = [RSURLRequestProcessor proccessRequest:aRequest isEdge:isEdge baseURL:nil];
        std::shared_ptr<rs::Request> request = rs::requestFromURLRequest(newRequest);
        request->setOriginalURL(rs::stdStringFromNSString(aRequest.URL.absoluteString));
        request->setOriginalScheme(rs::stdStringFromNSString(aRequest.URL.scheme));
        connectionProxy = std::make_shared<rs::ConnectionProxy>(request, currentProtocolName);
        connectionProxy.get()->setCallbacks(finishCallback, dataCallback, responseCallback, errorCallback);
    }
    
    return self;
}

- (void)start
{
    connectionProxy.get()->start();
}

@end








