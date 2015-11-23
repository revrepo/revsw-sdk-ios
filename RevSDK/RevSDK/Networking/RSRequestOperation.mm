//
//  RSRequestOperation.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSRequestOperation.h"
#import "RSUtils.h"

@interface RSRequestOperation ()

@property (nonatomic, copy) NSString* method;
@property (nonatomic, copy) NSString* endPoint;
@property (nonatomic, strong) NSDictionary* parameters;
@property (nonatomic, copy) void (^completionHandler)(NSData*, NSURLResponse*, NSError*);

@end

@implementation RSRequestOperation

- (instancetype)initWithEndPoint:(NSString *)aEndPoint method:(NSString *)aMethod parameters:(NSDictionary *)aParameters completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))aCompletionHandler
{
    self = [super init];
    
    if (self)
    {
        self.endPoint          = aEndPoint;
        self.method            = aMethod;
        self.parameters        = aParameters;
        self.completionHandler = aCompletionHandler;
    }
    
    return self;
}

- (void)main
{
    NSString* absoluteURLString = rs::absoluteURLStringFromEndPoint(self.endPoint);
    
    NSURL* URL = [NSURL URLWithString:absoluteURLString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    
    [NSURLProtocol setProperty:@YES forKey:rs::kRSURLProtocolHandledKey inRequest:request];
    
    NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData* data, NSURLResponse* response, NSError* error){
                                                                 
                                                                     if (self.completionHandler)
                                                                     {
                                                                         self.completionHandler(data, response, error);
                                                                     }
                                                                 
                                                                 }];
    [task resume];
}

@end
