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

#import "RSLocationService.h"

@interface RSLocation()
{
    double mLatitude;
    double mLongitude;
    double mAltitude;
    double mAccuracy;
    CLLocation* mLocation;
    
}

@property (copy, nonatomic, readwrite) NSString* lastLocationName;
@property (copy, nonatomic, readwrite) NSString* lastLocationCityName;

@end

@implementation RSLocation

@synthesize latitude = mLatitude;
@synthesize longitude = mLongitude;

- (id)initWithLocation:(CLLocation*)aLocation
{
    if (self = [super init])
    {
        mLatitude = aLocation.coordinate.latitude;
        mLongitude = aLocation.coordinate.longitude;
        mAccuracy = (aLocation.verticalAccuracy + aLocation.horizontalAccuracy) * 0.5;
        mLocation = aLocation;
        //[self fillLocationName];
    }
    return self;
}

- (id)initWithLatitude:(double)aLatitude
             longitude:(double)aLongitude
{
    if (self = [super init])
    {
        mLatitude = aLatitude;
        mLongitude = aLongitude;
        mAccuracy = -1.0;
        //[self fillLocationName];
    }
    return self;
}

- (id)initWithLatitude:(double)aLatitude
             longitude:(double)aLongitude
              accuracy:(double)aAccuracy
{
    if (self = [super init])
    {
        mLatitude = aLatitude;
        mLongitude = aLongitude;
        mAccuracy = aAccuracy;
        //[self fillLocationName];
    }
    return self;
}

// TODO: Unused code?
-(void)fillLocationName
{
    self.lastLocationName = @"";
    
//    CLLocation* loc = [self location];
//    
//    __weak RSLocation* weakSelf = self;
    
//    [[RSLocationService sharedService] getAddressForLocation:loc withCompletionBlock:^(NSString* s, NSString* city, NSError* e) {
//        weakSelf.lastLocationName = s;
//        weakSelf.lastLocationCityName = city;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kSXLocationServiceDidUpdate object:nil];
//    }];
}

- (CLLocation*)location
{
    if (mLocation == nil)
    {
        mLocation = [[CLLocation alloc] initWithCoordinate:self.coordinates
                                                  altitude:0.0
                                        horizontalAccuracy:self.accuracy
                                          verticalAccuracy:self.accuracy
                                                 timestamp:nil];
    }
    
    return mLocation;
}

- (CLLocationCoordinate2D)coordinates
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (double)accuracy
{
    return (mAccuracy > 0.0) ? (mAccuracy) : (0.0);
}

- (BOOL)hasAccuracy
{
    return mAccuracy > 0.0;
}

- (float)direction
{
    return [mLocation course];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"RSLocation: %lf %lf +- %lf", mLatitude, mLongitude, mAccuracy];
}

- (double)distanceFromLocation:(RSLocation*)aLocation
{
    return [self.location distanceFromLocation:aLocation.location];
}

- (double)distanceFromLatitude:(double)aLatitude longitude:(double)aLongitude
{
    CLLocation* location = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
    return [self.location distanceFromLocation:location];
}

@end

@interface RSLocationService()<CLLocationManagerDelegate>

@property (nonatomic, readwrite, strong) CLLocationManager* manager;
@property (nonatomic, readwrite, strong) RSLocation* lastLocation;


@end

@implementation RSLocationService

+ (RSLocationService*)sharedService
{
    static RSLocationService* mInstance = nil;
    static dispatch_once_t mToken;
    dispatch_once(&mToken, ^{
        mInstance = [[RSLocationService alloc] init];
    });
    return mInstance;
}

- (id)init
{
    if (self = [super init])
    {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
        self.manager.distanceFilter = 10; // meters
        self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        self.lastLocation = [[RSLocation alloc] initWithLatitude:0 longitude:0];
        
        [self.manager startUpdatingLocation];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    self.lastLocation = [[RSLocation alloc] initWithLocation:newLocation];
    
    //if(!self.lastLocationSelectedByUser)
   //     self.lastLocationSelectedByUser = self.lastLocation;
    
   // NSDictionary* d = [NSDictionary sx_dictionaryWithLocation:self.lastLocation
    //                                                    error:nil];
    // [[NSNotificationCenter defaultCenter] postNotificationName:kSXLocationServiceDidUpdate
    //                                                     object:nil
    //                                                   userInfo:d];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
   // NSDictionary* d = [NSDictionary sx_dictionaryWithLocation:self.lastLocation
    //                                                    error:error];
    // [[NSNotificationCenter defaultCenter] postNotificationName:kSXLocationServiceDidUpdate
    //                                                     object:nil
    //                                                   userInfo:d];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined)
        [manager requestWhenInUseAuthorization];
}

 -(BOOL)isEnabled
{
    return [CLLocationManager locationServicesEnabled];
}


- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    
}

- (NSString*)getLastLocation
{
    if(self.lastLocation.lastLocationName)
        return self.lastLocation.lastLocationName;
    
    [self.lastLocation fillLocationName];
    
    return [NSString stringWithFormat:@"%lf, %lf", self.lastLocation.latitude, self.lastLocation.longitude ];
    
} 

@end
