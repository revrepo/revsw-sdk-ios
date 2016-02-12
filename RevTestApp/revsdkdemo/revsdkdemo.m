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
    [self waitForStandardExpectationNotification:kRTLoadConfigirationTestNotification];
}

- (void)test_2_RequestTestLoop
{
     self.testLoop = [RTRequestTestLoop defaultTestLoop];
    [self.testLoop start];
 
    [self waitForStandardExpectationNotification:kRTRequestLoopDidFinishNotification];
}

- (void)test_3_ProtocolTestingSequence
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

- (void)test_4_StatsUploadTest
{
    self.statsUploadTester = [RTStatsUploadTester defaultTester];
    [self.statsUploadTester start];
    
   [self waitForStandardExpectationNotification:kRTStatsTesterDidFinishNotification];
}

- (void)test_5_ProtocolSwitchTest
{
    self.protocolTester = [RTProtocolSwitchTester defaultTester];
    [self.protocolTester start];
    
    [self waitForStandardExpectationNotification:kRTProtocolSwitchTesterDidFinish];
}

@end
