//
//  RSIPUtils.h
//  RevSDK
//
//  Created by Andrey Chernukha on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSIPUtils : NSObject

@property (nonatomic, copy, readonly) NSString* publicWifiIP;
@property (nonatomic, copy, readonly) NSString* publicCellularIP;
@property (nonatomic, copy, readonly) NSString* privateWiFiIP;
@property (nonatomic, copy, readonly) NSString* privateCellularIP;
@property (nonatomic, copy, readonly) NSString* netmask;

- (void)start;

@end
