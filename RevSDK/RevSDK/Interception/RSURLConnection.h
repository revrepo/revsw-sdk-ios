//
//  RVURLConnection.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSURLConnection;

@protocol RSURLConnectionDelegate

- (void) rs_connection:(nullable RSURLConnection *)connection didReceiveResponse:(nullable NSURLResponse *)response;

- (void) rs_connection:(nullable RSURLConnection *)connection didReceiveData:(nullable NSData *)data;
    
- (void) rs_connectionDidFinishLoading:(nullable RSURLConnection *)connection;

- (void) rs_connection:(nullable RSURLConnection *)connection didFailWithError:(nullable NSError *)error;

@end

@interface RSURLConnection : NSObject

@property (nonatomic, weak) id<RSURLConnectionDelegate> delegate;

+ (nullable instancetype)connectionWithRequest:(nullable NSURLRequest *)aRequest delegate:(nullable id<RSURLConnectionDelegate>)delegate;
- (void)start;

@end
