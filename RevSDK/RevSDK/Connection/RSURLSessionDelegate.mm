//
//  RSURLSessionDelegate.m
//  RevSDK
//
//  Created by Vlad Joss on 23.12.15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSURLSessionDelegate.h"
#import "RSURLRequestProcessor.h"

#include "Model.hpp"

@interface RSURLSessionDelegate ()
{
    std::weak_ptr<rs::Connection> connection;
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
        request = [RSURLRequestProcessor proccessRequest:request];
        completionHandler(request);
    }
}
// only for put and post
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//             didSendBodyData:(int64_t)bytesSent
//              totalBytesSent:(int64_t)totalBytesSent
//    totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
//{
//    auto owner = connection.lock();
//    owner->addSentBytesCount(bytesSent);
//} 

@end






