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


#import "RTConfigurationLoadObserver.h"
#import "RTUtils.h"

static BOOL configurationLoaded = NO;
static int refreshInterval      = 0;
static NSDate* lastDate         = nil;
static int loadsCounter         = 0;
static BOOL expectedToFail      = NO;
static const int kDeviation     = 5;
static const int kTotalLoads    = 5;

@implementation RTConfigurationLoadObserver

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"kConfigurationLoadedNotification"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification* aNote){
                                                      
                                                      NSLog(@".");
                                                  
                                                      if (configurationLoaded)
                                                      {
                                                          int interval = [[NSDate date] timeIntervalSinceDate:lastDate];
                                                          
                                                          if (interval < refreshInterval - kDeviation || interval > refreshInterval + kDeviation)
                                                          {
                                                              [self postErrorWithInterval:interval];
                                                          }
                                                          else
                                                          {
                                                              expectedToFail = NO;
                                                          }
                                                      }
                                                      
                                                      NSDictionary* userInfo = aNote.userInfo;
                                                      NSString* info         = userInfo[@"info_key"];
                                                      refreshInterval        = [info intValue];
                                                      lastDate               = [NSDate date];
                                                      configurationLoaded    = YES;
                                                      
                                                      loadsCounter++;
                                                      
                                                      if (loadsCounter == kTotalLoads)
                                                      {
                                                          [self postLoadNotificationWithMessage:@"Success" result:@YES];
                                                      }
                                                      
                                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kDeviation + refreshInterval) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                          
                                                          if (expectedToFail)
                                                          {
                                                              int interval = [[NSDate date] timeIntervalSinceDate:lastDate];
                                                              [self postErrorWithInterval:interval];
                                                          }
                                                          
                                                          expectedToFail = YES;
                                                         
                                                      });
                                                  }];
}

+ (void)postErrorWithInterval:(int)aInterval
{
    NSString* errorMessage = [NSString stringWithFormat:@"Load configuration test interval %d expected interval %d", aInterval, refreshInterval];

    [self postLoadNotificationWithMessage:errorMessage
                                   result:@NO];
}

+ (void)postLoadNotificationWithMessage:(NSString *)aMessage result:(NSNumber *)aResult
{
    NSDictionary* userInfo = @{
                               kRTErrorKey : aMessage,
                               kRTResultKey : aResult
                               };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRTLoadConfigirationTestNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

@end
