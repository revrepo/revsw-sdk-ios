//
//  RSURLSessionDelegate.m
//  RevSDK
//
//  Created by Vlad Joss on 23.12.15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSURLSessionDelegate.h"
#import "RSURLRequestProcessor.h"
#import "RSUtils.h"

#include "Model.hpp"

@interface RSURLSessionDelegate ()
{
    std::shared_ptr<rs::Connection> connection;
}
@end

@implementation RSURLSessionDelegate

- (void)setConnection:(std::shared_ptr<rs::Connection>)aConnection
{
    connection = aConnection;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    
    BOOL isEdgeFlag = rs::Model::instance()->currentProtocol()->protocolName() == rs::standardProtocolName();
    NSLog(@"Redirect with code %d", code);
    
    if (!request)
    {
        completionHandler(nil);
    }
    else if (rs::Model::instance()->currentOperationMode() == rs::kRSOperationModeInnerOff)
    {
        completionHandler(request);
    }
    else
    {
        request = [RSURLRequestProcessor proccessRequest:request isEdge:isEdgeFlag];
        completionHandler(request);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    connection->didReceiveData((__bridge void *)data);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    connection->didReceiveResponse((__bridge void *) response);
    
    if (completionHandler)
    {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    connection->didCompleteWithError((__bridge void*)error);
    [session invalidateAndCancel];
}

@end






