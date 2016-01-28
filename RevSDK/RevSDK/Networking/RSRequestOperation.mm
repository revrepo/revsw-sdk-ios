/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

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
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"]; // bug
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; // bug
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.body length]] forHTTPHeaderField:@"Content-Length"];
        request.HTTPBody = self.body;
    }
    
    [NSURLProtocol setProperty:@YES forKey:rs::kRSURLProtocolHandledKey inRequest:request];
    
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session                    = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask* task               = [session dataTaskWithRequest:request
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
