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


#import <XCTest/XCTest.h>
#import "RTRequestTestLoop.h"
#import "RTUtils.h"

static const int kConfigurationExpectationTimeout = 10;

@interface revsdkdemo : XCTestCase

@property (nonatomic, strong) RTRequestTestLoop* testLoop;

@end

@implementation revsdkdemo

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSLog(@"SETUP");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)waitForConfigurationLoad
{
    XCTestExpectation* configurationExpectation = [self expectationForNotification:@"kConfigurationLoadedNotification"
                                                                            object:nil
                                                                           handler:^BOOL(NSNotification* aNotification){
                                                                               
                                                                               [configurationExpectation fulfill];
                                                                               
                                                                               return YES;
                                                                           }];
    
    [self waitForExpectationsWithTimeout:kConfigurationExpectationTimeout handler:nil];
}

- (void)test_1_RequestTestLoop
{
    [self waitForConfigurationLoad];
    
    self.testLoop = [RTRequestTestLoop defaultTestLoop];
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
   
}

@end
