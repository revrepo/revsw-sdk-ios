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

@class RSURLConnection;

@protocol RSURLConnectionDelegate

- (void) rsconnection:(nullable RSURLConnection *)connection didReceiveResponse:(nullable NSURLResponse *)response;

- (void) rsconnection:(nullable RSURLConnection *)connection didReceiveData:(nullable NSData *)data;
    
- (void) rsconnectionDidFinishLoading:(nullable RSURLConnection *)connection;

- (void) rsconnection:(nullable RSURLConnection *)connection didFailWithError:(nullable NSError *)error;

- (void) rsconnection:(nullable RSURLConnection *)connection wasRedirectedToRequest:(nonnull NSURLRequest *)request redirectResponse:(nonnull NSURLResponse *)response;

@end

@interface RSURLConnection : NSObject

@property (nonatomic, weak) id<RSURLConnectionDelegate> delegate;

+ (nullable instancetype)connectionWithRequest:(nullable NSURLRequest *)aRequest delegate:(nullable id<RSURLConnectionDelegate>)delegate;
- (void)start;

@end
