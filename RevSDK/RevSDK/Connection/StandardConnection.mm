//
//  StandardConnection.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "StandardConnection.hpp"
#include "RSUtils.h"
#include "RSURLProtocol.h"
#include "Data.hpp"
#include "Response.hpp"
#include "Request.hpp"
#include "Error.hpp"
#include "RSUtilsBridge.hpp"

@interface TestedObject : NSObject

@property (nonatomic, strong) NSData* data;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, copy) NSString* revUrl;
@property (nonatomic, readonly) NSString* string;

@end

@implementation TestedObject

- (NSString *)string
{
    return [self description];
}

- (BOOL)isEqual:(TestedObject *)aObject
{
    return [self.string isEqualToString:aObject.string];
}

- (NSString *)description
{
    if (self.revUrl == nil)
    return [NSString stringWithFormat:@"%@ --- %lu", self.url, self.data.length]; //self.revUrl, (unsigned long)self.data.length];
    else
    return [NSString stringWithFormat:@"%@ --- %lu", [self.url stringByReplacingOccurrencesOfString:rs::kRSRevHost withString:self.revUrl], self.data.length];
}

@end

@interface Test : NSObject

@property (nonatomic, strong) NSMutableArray* array;

+ (id)instance;

@end

@implementation Test

+ (id)instance
{
    static id _instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    
    return _instance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.array = [NSMutableArray array];
        [self.array addObject:[NSMutableArray array]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadEnded)
                                                     name:@"LoadFinished"
                                                   object:nil];
    }
    
    return self;
}

- (void)loadEnded
{
    @synchronized(self) {
        
        if (self.array.count < 10)
        {
           [self.array addObject:[NSMutableArray array]];
        }
        else
        {
            [self print];
        }
    }
}

- (void)addTestedObject:(TestedObject *)aObject
{
    @synchronized(self)
    {
        NSMutableArray* array = self.array.lastObject;
        [array addObject:aObject];
    }
}

- (void)print
{
    for (int i = 0; i < self.array.count; i++)
    {
         NSMutableArray* ___array = self.array[i];
        
        NSLog(@"LOAD #%d count %lu", i + 1, ___array.count);
    }
    
    NSLog(@"\n\n\n\n");
    
    for (int i = 0; i < self.array.count; i++)
    {
        NSMutableArray* ___array = self.array[i];
        
        NSLog(@"LOAD #%d count %lu", i + 1, ___array.count);
        
        NSLog(@"Array %@", ___array);
    }
    
    NSMutableSet* directSet = [NSMutableSet set];
    NSMutableSet* sdkSet    = [NSMutableSet set];
    
    for (int i = 0; i < 10; i++)
    {
        NSArray* __array = self.array[i];
        
        if (i < 5)
        {
            [directSet addObjectsFromArray:__array];
        }
        else
        {
            [sdkSet addObjectsFromArray:__array];
        }
    }
    
    NSLog(@"\n\n\n\n");
    
    NSLog(@"DIRECT COUNT %lu SDK COUNT %lu", directSet.count, sdkSet.count);
    
    NSMutableSet* firstSet = [NSMutableSet setWithArray:self.array.firstObject];
    NSMutableSet* secondSet = [NSMutableSet setWithArray:self.array[1]];
    [firstSet minusSet:secondSet];
    [directSet minusSet:firstSet];
    
    NSLog(@"\n\n\n\n");
    
    NSLog(@"DIRECT COUNT %lu SDK COUNT %lu", directSet.count, sdkSet.count);
}

@end

namespace rs
{
    void StandardConnection::startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate)
    {
        std::shared_ptr<Connection> oAnchor = mWeakThis.lock();
        NSURLRequest* request               = URLRequestFromRequest(aRequest);
        NSMutableURLRequest* mutableRequest = request.mutableCopy;
        NSString* targetHost                = request.URL.host;
        
        if (!targetHost)
        {
            Error error;
            error.code     = 404;
            error.domain   = "com.revsdk";
            error.userInfo = std::map <std::string, std::string>();
            error.userInfo[errorDescriptionKey()] = "URL not supported";
            aDelegate->connectionDidFailWithError(oAnchor, error);
            return;
        }
        
        [NSURLProtocol setProperty:@YES forKey:kRSURLProtocolHandledKey inRequest:mutableRequest];

        NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session                           = [NSURLSession sessionWithConfiguration:sessionConfiguration];

        // It turns out that NSURLSession doesn't support synchronous calls
        // The only solution found on the web is to use semaphores, but it provides only pseudo synchronous behaviour and doesn't resolve the problem
        // Another solution is to use NSURLConnection, but it is deprecated, so I've decided to stick to NSURLSession by now
        
      //  NSLog(@"Request %p headers %@", mutableRequest, mutableRequest.allHTTPHeaderFields);
        
        //NSLog(@"CONNECTION %@", mutableRequest.URL);
        
        NSString* revURL = mutableRequest.allHTTPHeaderFields[@"X-Rev-Host"];
        
        NSURLSessionTask* task = [session dataTaskWithRequest:mutableRequest
                                            completionHandler:^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
                                                
                                                std::shared_ptr<Connection> anchor = oAnchor;

                                                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)aResponse;
                                                
                                                if (httpResponse.statusCode != 200)
                                                {
                                                    //NSLog(@"Response %@ current request %p ", httpResponse, request);
                                                }
                                                
                                                //NSString* str = [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding];
                                                //NSLog(@"URL %@ Rev %@ Data received %ld", httpResponse.URL, revURL, (unsigned long)aData.length);
                                                
                                                TestedObject* object = [TestedObject new];
                                                object.data = aData;
                                                object.url = httpResponse.URL.absoluteString;
                                                object.revUrl = revURL;
                                                
                                                [[Test instance] addTestedObject:object];
                                                
                                                if (!aError)
                                                {
                                                    Data data                          = dataFromNSData(aData);
                                                    std::shared_ptr<Response> response = responseFromHTTPURLResponse(httpResponse);
                                                    
                                                    aDelegate->connectionDidReceiveResponse(anchor, response);
                                                    aDelegate->connectionDidReceiveData(anchor, data);
                                                    aDelegate->connectionDidFinish(anchor);
                                                }
                                                else
                                                {
                                                    Error error = errorFromNSError(aError);
                                                    aDelegate->connectionDidFailWithError(anchor, error);
                                                }
                                            }];
        [task resume];
    }
}
