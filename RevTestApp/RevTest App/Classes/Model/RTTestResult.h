//
//  TestResult.h
//  RevTest App
//
//  Created by Vlad Joss on 06.01.16.
//
//
#import <Foundation/Foundation.h>

@interface RTTestResult : NSObject

+ (void)setShouldReportDataInMB:(BOOL)aShouldReportDataInMB;

@property (nonatomic, readwrite, strong) NSString* testName;
@property (nonatomic, readwrite, assign) NSInteger errorCode;
@property (nonatomic, readwrite, assign) CGFloat dataLength;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, readonly) NSString* durationString;
@property (nonatomic, readonly) NSString* dataLengthString;
@property (nonatomic, readonly) NSString* wholeString;
@property (nonnull, readonly) NSString* plainWholeString;
@property (nonatomic, readonly) NSString* nameString;

@end