//
//  AppDelegate.m
//  RevClient
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "AppDelegate.h"
#import <RevSDK/RevSDK.h>

@interface AppDelegate ()

@property (nonatomic, assign) CFHTTPMessageRef httpMessageRef;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [RevSDK startWithSDKKey:@"12345"];
    
    NSURL* url = [NSURL URLWithString:@"https://cdn.photographylife.com/wp-content/uploads/2014/06/Nikon-D810-Image-Sample-6.jpg"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString* proxyHost = @"52.88.151.82";
    NSNumber* proxyPort = [NSNumber numberWithInt: 8888];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDictionary *proxyDict = @{
                                @"HTTPEnable"  : [NSNumber numberWithInt:1],
                                (NSString *)kCFStreamPropertyHTTPProxyHost  : proxyHost,
                                (NSString *)kCFStreamPropertyHTTPProxyPort  : proxyPort,
                                
                                @"HTTPSEnable" : [NSNumber numberWithInt:1],
                                (NSString *)kCFStreamPropertyHTTPSProxyHost : proxyHost,
                                (NSString *)kCFStreamPropertyHTTPSProxyPort : proxyPort,
                                };
#pragma clang diagnostic pop
   configuration.connectionProxyDictionary = proxyDict;
    
  //  configuration.protocolClasses = @[NSClassFromString(@"RSURLProtocol")];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error){
    
        NSLog(@"Response %@ error %@", response, error);
    
    }];
    
    [task resume];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
