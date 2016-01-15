//
//  StandardSession.h
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/9/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSOriginSession : NSObject

+ (RSOriginSession*)instance;
- (void)createTaskWithRequest:(NSURLRequest*)aRequest
                     delegate:(id<NSURLSessionDataDelegate>)aDelegate;

@end
