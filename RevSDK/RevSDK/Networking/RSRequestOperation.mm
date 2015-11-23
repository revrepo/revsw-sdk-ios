//
//  RSRequestOperation.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSRequestOperation.h"
#import "RSUtils.h"

static const NSUInteger kRSResponseStatusCodeOk = 200;

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
                                                                 completionHandler:^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
                                                                 
                                                                     NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)aResponse;
                                                                     
                                                                     if (httpResponse.statusCode != kRSResponseStatusCodeOk)
                                                                     {
                                                                         if (!aError)
                                                                         {
                                                                             aError = [NSError errorWithDomain:@"com.revsdk"
                                                                                                          code:httpResponse.statusCode
                                                                                                      userInfo:@{
                                                                                                                 NSLocalizedDescriptionKey : @"Unknown error"
                                                                                                                 }];
                                                                         }
                                                                     }
                                                                     
                                                                     if (self.completionHandler)
                                                                     {
                                                                         self.completionHandler(aData, aResponse, aError);
                                                                     }
                                                                 }];
    [task resume];
}

@end
