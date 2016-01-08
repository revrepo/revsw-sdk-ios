//
//  RSURLRequestProcessor.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/27/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSURLRequestProcessor : NSObject

+ (NSURLRequest *)proccessRequest:(NSURLRequest *)aRequest isEdge:(bool)aIsEdge;

@end
