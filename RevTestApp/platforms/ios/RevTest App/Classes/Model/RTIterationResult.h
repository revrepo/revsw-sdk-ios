//
//  IterationResult.h
//  RevTest App
//
//  Created by Vlad Joss on 06.01.16.
//
//

#import <Foundation/Foundation.h>
#import "RTTestResult.h"

@interface RTIterationResult : NSObject

@property (nonatomic, strong) NSMutableArray* testResults;
@property (nonatomic, readonly, assign) BOOL valid; 

- (id) init;

- (void) pushResult:(RTTestResult*)aResult;


@end
