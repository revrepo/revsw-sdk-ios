//
//  RTTestCase.h
//  RevTest App
//
//  Created by Vlad Joss on 08.01.16.
//
//

#import <Foundation/Foundation.h>

@interface RTTestCase : NSObject

@property (nonatomic, readwrite, copy) NSString* testName;

@property (nonatomic, readwrite, copy) NSString* protocolID;

@property (nonatomic, readwrite, assign) NSInteger operationMode;

@end