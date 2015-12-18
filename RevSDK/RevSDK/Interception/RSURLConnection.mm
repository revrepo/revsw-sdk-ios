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
        
            [self.delegate connectionDidFinishLoading:self];
        };
        
        std::function<void(rs::Data)> dataCallback = [self](rs::Data aData){
           
            NSData* data = rs::NSDataFromData(aData);
            [self.delegate connection:self didReceiveData:data];
        };
        
        std::function<void(std::shared_ptr<rs::Response>)> responseCallback = [self](std::shared_ptr<rs::Response> aResponse){
            
            NSHTTPURLResponse* response = rs::NSHTTPURLResponseFromResponse(aResponse);
            [self.delegate connection:self didReceiveResponse:response];
        };
        
        std::function<void(rs::Error)> errorCallback = [self](rs::Error aError){
        
            NSError* error = rs::NSErrorFromError(aError);
            [self.delegate connection:self didFailWithError:error];
        };
        
        BOOL shouldRedirect      = [self shouldRedirectRequest:aRequest];
        NSURLRequest* newRequest = (aRequest.URL.host && shouldRedirect) ? [RSURLRequestProcessor proccessRequest:aRequest] : aRequest;
        connectionProxy          = std::make_shared<rs::ConnectionProxy>(rs::requestFromURLRequest(newRequest));
        connectionProxy.get()->setCallbacks(finishCallback, dataCallback, responseCallback, errorCallback);
    }
    
    return self;
}

- (BOOL)shouldRedirectRequest:(NSURLRequest *)aRequest
{
    NSURL* URL             = [aRequest URL];
    NSString* host         = [URL host];
    std::string domainName = rs::stdStringFromNSString(host);
    BOOL should            = rs::Model::instance()->shouldTransportDomainName(domainName) &&
                             ![NSURLProtocol propertyForKey:rs::kRSURLProtocolHandledKey inRequest:aRequest] &&
                             !aRequest.isFileRequest;
    return should;
}

- (void)start
{
    connectionProxy.get()->start();
}

@end
