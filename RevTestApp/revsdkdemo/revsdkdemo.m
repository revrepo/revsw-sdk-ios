//
//  revsdkdemo.m
//  revsdkdemo
//
//  Created by Andrey Chernukha on 2/9/16.
//
//

#import <XCTest/XCTest.h>
#import "RTRequestTestLoop.h"
#import "RTUtils.h"

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

- (void)testRequestTestLoop
{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    const int kConfigurationExpectationTimeout = 10;
    
     XCTestExpectation* configurationExpectation = [self expectationForNotification:@"kConfigurationLoadedNotification"
                                                                             object:nil
                                                                            handler:^BOOL(NSNotification* aNotification){
                                                                            
                                                                                [configurationExpectation fulfill];
                                                            
                                                                                return YES;
                                                                            }];
    
    [self waitForExpectationsWithTimeout:kConfigurationExpectationTimeout handler:nil];
    
    self.testLoop = [RTRequestTestLoop defaultTestLoop];
    [self.testLoop start];
    
    XCTestExpectation* expectation = [self expectationForNotification:kRTRequestLoopDidFinishNotification
                                                               object:nil
                                                              handler:^BOOL(NSNotification *aNotification){
                                                                  
                                                                  [expectation fulfill];
                                                                  
                                                                  NSDictionary* userInfo = aNotification.userInfo;
                                                                  NSNumber* result       = userInfo[kRTResultKey];
                                                                  
                                                                  XCTAssertTrue(result.boolValue);
                                                                  
                                                                  return YES;
                                                              }];
    
    [self waitForExpectationsWithTimeout:INT_MAX handler:nil];
}

@end
