//
//  RSRequestOperation.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSRequestOperation : NSOperation

- (instancetype)initWithURLString:(NSString *)aURLString
                           method:(NSString *)aMethod
                       parameters:(NSDictionary *)aParameters
                completionHandler:(void(^)(NSData*, NSURLResponse*, NSError*))aCompletionHandler;

@end
