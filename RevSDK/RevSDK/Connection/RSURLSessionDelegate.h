//
//  NSURLSessionDelegate.h
//  RevSDK
//
//  Created by Vlad Joss on 23.12.15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//
#import <Foundation/Foundation.h>

#include <memory>
#include "Connection.hpp"

@interface RSURLSessionDelegate : NSObject <NSURLSessionDataDelegate>

- (void)setConnection:(std::shared_ptr<rs::Connection>)aConnection;

@end