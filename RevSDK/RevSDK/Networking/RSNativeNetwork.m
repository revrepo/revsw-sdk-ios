//
//  RSNativeNetwork.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSNativeNetwork.h"
#import "RSRequestOperation.h"

@interface RSNativeNetwork ()

@property (nonatomic, strong) NSOperationQueue* operationQueue;

@end

@implementation RSNativeNetwork

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.operationQueue = [NSOperationQueue new];
    }
    
    return self;
}

- (void)loadConfigurationWithCompletionBlock:(void (^)(NSData *, NSURLResponse *, NSError *))aCompletionBlock
{
    void (^completionHandler)(NSData*, NSURLResponse*, NSError*) = ^(NSData* data, NSURLResponse* response, NSError* error){
    
       if (aCompletionBlock)
       {
           aCompletionBlock(data, response, error);
       }
    };
    
    RSRequestOperation* requestOperation = [[RSRequestOperation alloc] initWithEndPoint:@"sdk/config"
                                                                                 method:@"GET"
                                                                             parameters:nil
                                                                      completionHandler:completionHandler];
    [self.operationQueue addOperation:requestOperation];
}

@end
