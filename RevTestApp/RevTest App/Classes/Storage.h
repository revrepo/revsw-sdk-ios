#import <Foundation/Foundation.h>

@interface Storage : NSObject

+ (NSArray*)nativeMobileAppHistory;
+ (void)setNativeMobileAppHistory:(NSArray*)array;

+ (NSArray*)mobileWebHistory;
+ (void)setMobileWebHistory:(NSArray*)array;

@end
