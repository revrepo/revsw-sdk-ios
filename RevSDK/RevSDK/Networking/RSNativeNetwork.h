//
//  RSNativeNetwork.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSNativeNetwork : NSObject

- (void)loadConfigurationWithCompletionBlock:(void(^)(NSData*, NSURLResponse*, NSError*))aCompletionBlock;

@end
