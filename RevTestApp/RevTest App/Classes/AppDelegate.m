/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
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


#import "objc/runtime.h"

#import "AppDelegate.h"
#import "RTStartViewController.h"

#import <RevSDK/RevSDK.h>

#import "NSURLCache+ForceNoCache.h"

#if TARGET_IPHONE_SIMULATOR
#else
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#define USE_CRASHLYTICS 1
#endif

static BOOL isRunningTests(void)
{
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

id setBeingRemoved(id self, SEL selector, ...)
{
    return nil;
}

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController* navigationController;

@end

@implementation AppDelegate

@synthesize window;


/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{

    // racer: 0efbbd35-a131-4419-b330-00de5eb3696b
    // demo1: 42e276ea-1823-4945-baa4-8747f08d0abe
    // demo2: a2e23128-4685-41d3-8e49-c8e76c1688ef
    [RevSDK startWithSDKKey:@"0efbbd35-a131-4419-b330-00de5eb3696b"]; // Racer key for 65apps
    
    if (!isRunningTests())
    {
        [NewRelicAgent startWithApplicationToken:@"AA289b5c865e93a480d7cffca562cf1a44ed67e5bb"];
    }
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

#if __has_feature(objc_arc)
        self.window = [[UIWindow alloc] initWithFrame:screenBounds];
#else
        self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
#endif
    self.window.autoresizesSubviews = YES;

#if __has_feature(objc_arc)
      //  self.viewController = [[MainViewController alloc] init];
#else
        self.viewController = [[[MainViewController alloc] init] autorelease];
#endif

    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
    // self.viewController.startPage = @"index.html";

    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.

#if USE_CRASHLYTICS
    [Fabric with:@[[Crashlytics class]]];
#endif
    
    RTStartViewController* startViewController = [[RTStartViewController alloc] initWithNibName:@"RTStartViewController" bundle:[NSBundle mainBundle]];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:startViewController];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    // in order to get rid of iOS bug. unrecognized selector exception is thrown in the WebActionDisablingCALayerDelegate private Apple class otherwise
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    Class class = NSClassFromString(@"WebActionDisablingCALayerDelegate");
    class_addMethod(class, @selector(willBeRemoved), setBeingRemoved, NULL);
    class_addMethod(class, @selector(removeFromSuperview), setBeingRemoved, NULL);
    class_addMethod(class, @selector(setBeingRemoved:), setBeingRemoved, NULL);
    class_addMethod(class, @selector(_webCustomViewWillBeRemovedFromSuperview), setBeingRemoved, NULL);
    class_addMethod(class, @selector(layer), setBeingRemoved, NULL);
    class_addMethod(class, @selector(superview), setBeingRemoved, NULL);
    class_addMethod(class, @selector(setNode:), setBeingRemoved, NULL);
    class_addMethod(class, @selector(_webCustomViewWasRemovedFromSuperview:), setBeingRemoved, NULL);
#pragma clang diagnostic pop*/

    return YES;
}

// this happens while we are running ( in the background, or from within our own app )
// only valid if RevTest App-Info.plist specifies a protocol to handle
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    if (!url) {
        return NO;
    }

    // all plugins will get the notification, and their handlers will be called
//    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];

    return YES;
}

// repost all remote and local notification using the default NSNotificationCenter so multiple plugins may respond
- (void)            application:(UIApplication*)application
    didReceiveLocalNotification:(UILocalNotification*)notification
{
    // re-post ( broadcast )
//    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

#ifndef DISABLE_PUSH_NOTIFICATIONS

    - (void)                                 application:(UIApplication*)application
        didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
    {
        // re-post ( broadcast )
        NSString* token = [[[[deviceToken description]
            stringByReplacingOccurrencesOfString:@"<" withString:@""]
            stringByReplacingOccurrencesOfString:@">" withString:@""]
            stringByReplacingOccurrencesOfString:@" " withString:@""];

//        [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotification object:token];
    }

    - (void)                                 application:(UIApplication*)application
        didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
    {
        // re-post ( broadcast )
//        [[NSNotificationCenter defaultCenter] postNotificationName:CDVRemoteNotificationError object:error];
    }
#endif
/*
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
#else
- (UIInterfaceOrientationMask)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
#endif
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);

    return supportedInterfaceOrientations;
}
*/
- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
