//
//  StaticStatsProvider.h
//  RevSDK
//
//  Created by Vlad Joss on 25.12.15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

@interface RSStaticStatsProvider : NSObject

@property (nonatomic, readonly, assign) int cores;

//@property (copy, nonatomic, readonly) NSString* lastLocationName;

+ (RSStaticStatsProvider*)sharedProvider;

@end