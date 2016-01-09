//
//  StandardSession.h
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/9/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Connection.hpp"

@interface RSStandardSession : NSObject

+ (RSStandardSession*)instance;
- (void)createTaskWithRequest:(NSURLRequest*)aRequest
                                connection:(std::shared_ptr<rs::Connection>)aConnection;

@end
