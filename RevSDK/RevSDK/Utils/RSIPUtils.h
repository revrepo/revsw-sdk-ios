//
//  RSIPUtils.h
//  RevSDK
//
//  Created by Andrey Chernukha on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSIPUtils : NSObject

@property (nonatomic, copy) NSString* publicWifiIP;
@property (nonatomic, copy) NSString* publicCellularIP;
@property (nonatomic, copy) NSString* privateWiFiIP;
@property (nonatomic, copy) NSString* privateCellularIP;

- (void)start;

@end
