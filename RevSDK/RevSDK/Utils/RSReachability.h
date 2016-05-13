/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>


typedef enum : NSInteger {
	kRSNotReachable = 0,
	kRSReachableViaWiFi,
	kRSReachableViaWWAN,
    kRSFakeStatus
} RSNetworkStatus;


extern NSString *kRSReachabilityChangedNotification;


@interface RSReachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)rs_reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)rs_reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)rs_reachabilityForInternetConnection;

/*!
 * Checks whether a local WiFi connection is available.
 */
+ (instancetype)rs_reachabilityForLocalWiFi;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL)rs_startNotifier;
- (void)rs_stopNotifier;

- (RSNetworkStatus)rs_currentReachabilityStatus;
- (NSString *)networkStatusString;

/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)rs_connectionRequired;

- (void)prepareForFake;

@property (nonatomic, assign, getter=isFake) BOOL fake;

@end


