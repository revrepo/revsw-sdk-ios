//
//  RSRequestOperation.m
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSRequestOperation.h"
#import "RSUtils.h"
#import <UIKit/UIKit.h>

static const NSUInteger kRSResponseStatusCodeOk = 200;

@interface RSRequestOperation ()

@property (nonatomic, copy) NSString* method;
@property (nonatomic, copy) NSString* URLString;
@property (nonatomic, strong) NSData* body;
@property (nonatomic, copy) void (^completionHandler)(NSData*, NSURLResponse*, NSError*);

@end

@implementation RSRequestOperation

- (instancetype)initWithURLString:(NSString *)aURLString method:(NSString *)aMethod body:(NSData *)aBody completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))aCompletionHandler
{
    self = [super init];
    
    if (self)
    {
        self.URLString         = aURLString;
        self.method            = aMethod;
        self.completionHandler = aCompletionHandler;
        self.body              = aBody;
    }
    
    return self;
}

- (void)main
{
    NSURL* URL                   = [NSURL URLWithString:self.URLString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod           = self.method;
    
    if ([request.HTTPMethod isEqualToString:@"POST"] || [request.HTTPMethod isEqualToString:@"PUT"])
    {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.body length]] forHTTPHeaderField:@"Content-Length"];
        request.HTTPBody = self.body;
    }
    
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
