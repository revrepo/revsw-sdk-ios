//
//  LogStorage.h
//  RevSDK
//
//  Created by Andrey Chernukha on 2/4/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogStorage : NSObject

+ (void)save:(NSString *)aString;
+ (NSArray*)allDumps;

@end
