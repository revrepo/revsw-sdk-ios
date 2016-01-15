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
#import <CoreLocation/CoreLocation.h> 

@class CLLocation;

@interface RSLocation : NSObject

@property (nonatomic, readonly, strong) CLLocation* location;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D coordinates;
@property (nonatomic, readonly, assign) double latitude;
@property (nonatomic, readonly, assign) double longitude;
@property (nonatomic, readonly, assign) double accuracy;

@property (nonatomic, readonly, assign) float direction;

@property (nonatomic, readonly, assign) BOOL hasAccuracy;

@property (copy, nonatomic, readonly) NSString* lastLocationName;
@property (copy, nonatomic, readonly) NSString* lastLocationCityName;

- (id)initWithLocation:(CLLocation*)aLocation;
- (id)initWithLatitude:(double)aLatitude
             longitude:(double)aLongitude;
- (id)initWithLatitude:(double)aLatitude
             longitude:(double)aLongitude
              accuracy:(double)aAcciracy;

- (double)distanceFromLocation:(RSLocation*)aLocation;
- (double)distanceFromLatitude:(double)aLatitude longitude:(double)aLongitude;

@end

@interface RSLocationService : NSObject

@property (nonatomic, readonly, strong) RSLocation* lastLocation;
@property (nonatomic, readonly) BOOL isEnabled;

+ (RSLocationService*)sharedService;

- (NSString*)getLastLocation;
- (NSString*)getLastUserSelectedLocation; 

@end
