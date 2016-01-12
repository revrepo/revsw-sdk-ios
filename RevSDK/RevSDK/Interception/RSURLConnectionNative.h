//
//  RSURLConnectionNative.h
//  RevSDK
//
//  Created by Andrey Chernukha on 1/6/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

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
