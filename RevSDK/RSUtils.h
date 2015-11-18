//
//  RVUtils.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <memory>

#import <Foundation/Foundation.h>

@class Request;

extern NSString* const kRVURLProtocolHandledKey;

@interface RSUtils : NSObject

+ (std::shared_ptr<Request>)t;

@end
