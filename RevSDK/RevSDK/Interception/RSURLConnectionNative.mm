//
//  RSURLConnectionNative.m
//  RevSDK
//
//  Created by Andrey Chernukha on 1/6/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import "RSURLConnectionNative.h"
#import "Connection.hpp"

@implementation RSURLConnectionNative

- (instancetype)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    self = [super initWithRequest:request delegate:delegate];
    
    if (self)
    {
        NSDate* now              = [NSDate date];
        NSTimeInterval timestamp = [now timeIntervalSince1970];
        _startTimestamp          = @(timestamp);
        int connectionId         = rs::Connection::getLastConnectionId();
        _connectionId            = @(connectionId);
    }
    
    return self;
}

@end
