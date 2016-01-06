//
//  TestResult.h
//  RevTest App
//
//  Created by Vlad Joss on 06.01.16.
//
//
#import <Foundation/Foundation.h>

@interface RTTestResult : NSObject

@property (nonatomic, readwrite, strong) NSString* testName;

@property (nonatomic, readwrite, assign) NSInteger errorCode;

@property (nonatomic, readwrite, assign) NSInteger dataLength;

@end