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

@class RSURLConnectionNative;

@protocol RSURLConnectionNativeDelegate

- (void)connection:(nonnull RSURLConnectionNative *)aConnection didFailWithError:(nonnull NSError *)error;
- (void)connectionDidFinish:(nonnull RSURLConnectionNative *)aConnection;
- (void)connection:(nonnull RSURLConnectionNative *)aConnection didReceiveData:(nonnull NSData *)data;
- (void)connection:(nonnull RSURLConnectionNative *)aConnection didReceiveResponse:(nonnull NSURLResponse *)response;

@end

@interface RSURLConnectionNative : NSObject<NSURLSessionDataDelegate>

@property (nonatomic, strong, nullable) NSNumber* connectionId;
@property (nonatomic, strong, nullable) NSNumber* startTimestamp;
@property (nonatomic, strong, nullable) NSNumber* totalBytesReceived;
@property (nonatomic, strong, nullable) NSNumber* endTimestamp;
@property (nonatomic, strong, nullable) NSNumber* firstByteTimestamp;
@property (nonatomic, strong, nullable) NSURLRequest* request;
@property (nonatomic, strong, nullable) NSHTTPURLResponse* response;
@property (nonatomic, weak)   id<RSURLConnectionNativeDelegate> delegate;

- (nullable instancetype)initWithRequest:(nonnull NSURLRequest *)aRequest delegate:(nullable id<RSURLConnectionNativeDelegate>)aDelegate;
- (void)start;

@end
