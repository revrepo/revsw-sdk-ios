/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

#import <Foundation/Foundation.h>

@interface RSIPUtils : NSObject

@property (nonatomic, copy, readonly) NSString* publicWifiIP;
@property (nonatomic, copy, readonly) NSString* publicCellularIP;
@property (nonatomic, copy, readonly) NSString* privateWiFiIP;
@property (nonatomic, copy, readonly) NSString* privateCellularIP;
@property (nonatomic, copy, readonly) NSString* netmask;
@property (nonatomic, copy, readonly) NSString* dns1;
@property (nonatomic, copy, readonly) NSString* dns2;
@property (nonatomic, readonly)       NSString* gateway;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
