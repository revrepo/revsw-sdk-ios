//
//  RSURLConnectionNative.h
//  RevSDK
//
//  Created by Andrey Chernukha on 1/6/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSURLConnectionNative : NSURLConnection

@property (nonatomic, strong) NSNumber* connectionId;
@property (nonatomic, strong) NSNumber* startTimestamp;
@property (nonatomic, strong) NSNumber* totalBytesReceived;
@property (nonatomic, strong) NSNumber* endTimestamp;
@property (nonatomic, strong) NSNumber* firstByteTimestamp;

@end
