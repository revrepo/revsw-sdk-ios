//
//  RSURLRequestProcessor.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/27/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSURLRequestProcessor : NSObject

+ (NSMutableURLRequest *)proccessRequest:(NSURLRequest *)aRequest isEdge:(BOOL)aIsEdge baseURL:(NSURL*)aBaseURL;

@end
