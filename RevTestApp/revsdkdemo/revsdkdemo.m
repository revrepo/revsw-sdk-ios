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
#import "RTStatsUploadTester.h"
#import "RTUtils.h"
#import "RTProtocolSwitchTester.h"

#define kRSStandardNotificationHandler ^BOOL(NSNotification* aNotification){ return YES; }

static const int kConfigurationExpectationTimeout = 10;
static const int kProtocolTestingTimeout          = 10;

@interface revsdkdemo : XCTestCase

@property (nonatomic, strong) RTRequestTestLoop* testLoop;
@property (nonatomic, strong) RTStatsUploadTester* statsUploadTester;
@property (nonatomic, strong) RTProtocolSwitchTester* protocolTester;

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
                          timeoutHandler:nil
                     notificationHandler:kRSStandardNotificationHandler];
}

- (void)waitForProtocolsTestingEndWithFailureDescription:(NSString *)aFailureDescription
{
    id timeoutHandler = ^(NSError* error){
        
        if (error)
        {
            [self recordFailureWithDescription:aFailureDescription
                                        inFile:@__FILE__
                                        atLine:0
                                      expected:YES];
        }
    };
    
    [self waitForExpectationsWithTimeout:kProtocolTestingTimeout
                        notificationName:@"kProtocolTestingOverNotification"
                          timeoutHandler:timeoutHandler
                     notificationHandler:kRSStandardNotificationHandler];
}

- (void)waitForExpectationsWithTimeout:(NSTimeInterval)aTimeout notificationName:(NSString *)aNotificationName timeoutHandler:(void(^)(NSError *))aHandler notificationHandler:(BOOL (^)(NSNotification*))aNotificationHandler
{
    [self expectationForNotification:aNotificationName
                              object:nil
                             handler:aNotificationHandler];
    
    [self waitForExpectationsWithTimeout:aTimeout handler:aHandler];
}

- (void)waitForStandardExpectationNotification:(NSString *)aNotificationName
{
    id notificationHandler = ^BOOL(NSNotification * aNotification){
        
        NSDictionary* userInfo = aNotification.userInfo;
        NSNumber* result       = userInfo[kRTResultKey];
        NSString* errorMessage = userInfo[kRTErrorKey];
        
        XCTAssertTrue(result.boolValue, @" %@", errorMessage);
        
        return YES;
    };
    
    [self waitForExpectationsWithTimeout:INT_MAX
                        notificationName:aNotificationName
                          timeoutHandler:nil
                     notificationHandler:notificationHandler];
}

- (void)test_1_ConfigurationLoadTest
{
    NSLog(@"TEST 1 STARTED!");
    [self waitForStandardExpectationNotification:kRTLoadConfigirationTestNotification];
    NSLog(@"TEST 1 FINISHED!");
}

- (void)test_2_RequestTestLoop
{
    NSLog(@"TEST 2 STARTED!");
     self.testLoop = [RTRequestTestLoop defaultTestLoop];
    [self.testLoop start];
 
    [self waitForStandardExpectationNotification:kRTRequestLoopDidFinishNotification];
    NSLog(@"TEST 2 FINISHED!");
}

- (void)test_3_ProtocolTestingSequence
{
    NSLog(@"TEST 3 STARTED!");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CTRadioAccessTechnologyDidChangeNotification
                                                        object:nil];

    [self waitForProtocolsTestingEndWithFailureDescription:@"Protocol testing failed after changing radio access technology"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kRSFakeNetworkStatusChanged"
                                                        object:nil];
    
    [self waitForProtocolsTestingEndWithFailureDescription:@"Protocol testing failed after changing network reachability"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReturnFakeSSID"
                                                        object:nil];

    [self waitForProtocolsTestingEndWithFailureDescription:@"Protocol testing failed after changing network reachability"];
    
    NSLog(@"TEST 3 FINISHED!");
}

- (void)test_4_StatsUploadTest
{
    NSLog(@"TEST 4 STARTED!");
    
    self.statsUploadTester = [RTStatsUploadTester defaultTester];
    [self.statsUploadTester start];
    
   [self waitForStandardExpectationNotification:kRTStatsTesterDidFinishNotification];
    
    NSLog(@"TEST 4 FINISHED!");
}

- (void)test_5_ProtocolSwitchTest
{
    NSLog(@"TEST 5 STARTED!");
    
    self.protocolTester = [RTProtocolSwitchTester defaultTester];
    [self.protocolTester start];
    
    [self waitForStandardExpectationNotification:kRTProtocolSwitchTesterDidFinish];
    NSLog(@"TEST 5 FINISHED!");
}

- (void)test_6_OffModeTest
{
    NSLog(@"TEST 6 STARTED!");
    
    self.testLoop = [RTRequestTestLoopOffMode defaultTestLoop];
    
    [self.testLoop start];
    
    [self waitForStandardExpectationNotification:kRTOperationModeOffTestDidFinish];
    
    NSLog(@"TEST 6 FINISHED!");
}

@end
