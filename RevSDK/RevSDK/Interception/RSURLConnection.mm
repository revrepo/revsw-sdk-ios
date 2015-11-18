//
//  RVURLConnection.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <stdio.h>
#import <memory>

#import "RSURLConnection.h"
#import "ConnectionProxy.h"

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
        
        connectionProxy = std::make_shared<rs::ConnectionProxy>(aRequest);
    }
    
    return self;
}

- (void)start
{
    NSLog(@"MAIN THREAD %d", [NSThread isMainThread]);
}

@end
