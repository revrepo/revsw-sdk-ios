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
    void (^completionHandler)(NSData*, NSURLResponse*, NSError*) = ^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
    
        NSString* json = @"{\"app_name\": \"RevClient\",\
                            \"os\" : \"ios\",\
        \"configs\" : {\
        \"sdk_release_version\" : 1.0,\
        \"configuration_api_url\" : \"https://rev-200.revdn.net\",\
        \"configuration_refresh_interval_sec\" : 10,\
        \"configuration_stale_timeout_sec\" : 100,\
        \"edge_host\" : \"rev-200.revdn.net\",\
        \"operation_mode\" : \"transfer_and_report\",\
        \"allowed_transport_protocols\" : [\"standard\"],\
        \"initial_transport_protocol\" : \"standard\",\
        \"transport_monitoring_url\" : \"https://rev-200.revdn.net\",\
        \"stats_reporting_url\" : \"https://rev-200.revdn.net\",\
        \"stats_reporting_interval\" : 100,\
        \"stats_reporting_level\" : \"out_of_band\",\
        \"stats_reporting_max_request_per_report\" : 1,\
        \"domains_provisioned_list\" : [ \"mbeans.com\"],\
        \"domains_white_list\" : [\"mbeans.com\"],\
        \"domains_black_list\" : [] }}";
        
        
        NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];

       if (aCompletionBlock)
       {
           aCompletionBlock(data, aResponse, nil);
       }
    };
    
    RSRequestOperation* requestOperation = [[RSRequestOperation alloc] initWithEndPoint:@"sdk/config"
                                                                                 method:@"GET"
                                                                             parameters:nil
                                                                      completionHandler:completionHandler];
    [self.operationQueue addOperation:requestOperation];
}

@end
