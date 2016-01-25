#import "Storage.h"

#define DEFAULTS [NSUserDefaults standardUserDefaults]

static NSString* const kNativeMobileAppHistory = @"NativeMobileAppHistory";
static NSString* const kMobileWebHistory = @"MobileWebHistory";

@implementation Storage

+ (NSArray*)nativeMobileAppHistory
{
    NSArray* array = [DEFAULTS objectForKey:kNativeMobileAppHistory];
    return (array == nil ? [NSArray new] : array);
}

+ (void)setNativeMobileAppHistory:(NSArray*)array
{
    [DEFAULTS setObject:array forKey:kNativeMobileAppHistory];
    [DEFAULTS synchronize];
}

+ (NSArray*)mobileWebHistory
{
    NSArray* array = [DEFAULTS objectForKey:kMobileWebHistory];
    return (array == nil ? [NSArray new] : array);
}

+ (void)setMobileWebHistory:(NSArray*)array
{
    [DEFAULTS setObject:array forKey:kMobileWebHistory];
    [DEFAULTS synchronize];
}

@end
