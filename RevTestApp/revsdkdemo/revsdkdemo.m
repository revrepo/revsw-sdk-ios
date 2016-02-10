/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
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

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <XCTest/XCTest.h>

#import "RTRequestTestLoop.h"
#import "RTUtils.h"
#import "RTConfigurationObserver.h"

static const int kConfigurationExpectationTimeout = 10;
static const int kProtocolTestingTimeout          = 10;

@interface revsdkdemo : XCTestCase

@property (nonatomic, strong) RTRequestTestLoop* testLoop;

@end

@implementation revsdkdemo

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)waitForConfigurationLoad
{
    [self waitForExpectationsWithTimeout:kConfigurationExpectationTimeout
                        notificationName:@"kConfigurationLoadedNotification"
                          timeoutHandler:nil];
}

- (void)waitForProtocolsTestingEndWithFailureDescription:(NSString *)aFailureDescription
{
    [self waitForExpectationsWithTimeout:kProtocolTestingTimeout
                        notificationName:@"kProtocolTestingOverNotification"
                          timeoutHandler:^(NSError* error){
                              
                              if (error)
                              {
                                  [self recordFailureWithDescription:aFailureDescription
                                                              inFile:@__FILE__
                                                              atLine:0
                                                            expected:YES];
                              }
                          }];
}

- (void)waitForExpectationsWithTimeout:(NSTimeInterval)aTimeout notificationName:(NSString *)aNotificationName timeoutHandler:(void(^)(NSError *))aHandler
{
    XCTestExpectation* expectation = [self expectationForNotification:aNotificationName
                                                                            object:nil
                                                                           handler:^BOOL(NSNotification* aNotification){
                                                                               
                                                                               [expectation fulfill];
                                                                               
                                                                               return YES;
                                                                           }];
    
    [self waitForExpectationsWithTimeout:aTimeout handler:aHandler];
}

- (void)test_1_RequestTestLoop
{
    if (![RTConfigurationObserver configurationLoaded])
    {
        [self waitForConfigurationLoad];
    }
    
     self.testLoop = [[RTRequestTestLoop alloc] initWithDomains:@[@"httpbin.org"]
                                                  numberOfTests:1
                                             numberOfFullPasses:3];
    [self.testLoop start];
    
    XCTestExpectation* expectation = [self expectationForNotification:kRTRequestLoopDidFinishNotification
                                                               object:nil
                                                              handler:^BOOL(NSNotification *aNotification){
                                                                  
                                                                  [expectation fulfill];
                                                                  
                                                                  NSDictionary* userInfo = aNotification.userInfo;
                                                                  NSNumber* result       = userInfo[kRTResultKey];
                                                                  NSString* errorMessage = userInfo[kRTErrorKey];
                                                                  
                                                                  XCTAssertTrue(result.boolValue, @" %@", errorMessage);
                                                                  
                                                                  return YES;
                                                              }];
    
    [self waitForExpectationsWithTimeout:INT_MAX handler:nil];
}

- (void)test_2_ProtocolTestingSequence
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CTRadioAccessTechnologyDidChangeNotification
                                                        object:nil];

    [self waitForProtocolsTestingEndWithFailureDescription:@"Protocol testing failed after changing radio access technology"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kRSFakeNetworkStatusChanged"
                                                        object:nil];
    
    [self waitForProtocolsTestingEndWithFailureDescription:@"Protocol testing failed after changing network reachability"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReturnFakeSSID"
                                                        object:nil];

    [self waitForProtocolsTestingEndWithFailureDescription:@"Protocol testing failed after changing network reachability"];
}

@end
