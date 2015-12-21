//
//  RTTestCycleInfo.h
//  RevTest App
//
//  Created by Vlad Joss on 21.12.15.
//
//

#import <Foundation/Foundation.h>

@interface RTTestCycleInfo : NSObject

@property (nonatomic, readwrite, strong) NSString* asisSentChecksum;
@property (nonatomic, readwrite, strong) NSString* asisRcvdChecksum;
@property (nonatomic, readwrite, strong) NSString* edgeSentChecksum;
@property (nonatomic, readwrite, strong) NSString* edgeRcvdChecksum;

@property (nonatomic, readwrite, strong) NSString* method;

@property (nonatomic, readonly, assign) BOOL valid;

@property (nonatomic, readwrite, assign) NSInteger errorAsIs;
@property (nonatomic, readwrite, assign) NSInteger errorEdge;

@end
