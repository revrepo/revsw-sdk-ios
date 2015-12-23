//
//  RSURLSessionDelegate.m
//  RevSDK
//
//  Created by Vlad Joss on 23.12.15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSURLSessionDelegate.h"
#import "RSURLRequestProcessor.h"

@implementation RSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    
    NSLog(@"Redirect with code %d", code);
    
    if (!request)
    {
        completionHandler(nil);
    }
    else
    {
        request = [RSURLRequestProcessor proccessRequest:request];
        completionHandler(request);
    }
}

@end