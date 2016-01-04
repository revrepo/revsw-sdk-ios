//
//  NativeNetworkEventsHandler.cpp
//  RevSDK
//
//  Created by Vlad Joss on 04.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#include "NativeNetworkEventsHandler.hpp"

#include "RSReachability.h"

using namespace rs;

NativeNetworkEventsHandler::NativeNetworkEventsHandler(INetworkEventsDelegate* aDelegate) :
mDelegate(aDelegate),
mNativeHandle(nullptr),
mNativeTelephonyHandle(nullptr)
{
    RSReachability* internetConnection = [RSReachability rs_reachabilityForInternetConnection];
    [internetConnection rs_startNotifier];
    
    
   id observer =  [[NSNotificationCenter defaultCenter] addObserverForName:kRSReachabilityChangedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification* aNotification){
                                                  
                                                      
                                                      RSReachability* noteObject = [aNotification object];;
                                                      
                                                      if (noteObject)
                                                      {
                                                          const RSNetworkStatus old = (RSNetworkStatus)mNetworkStatusCode;
                                                          mNetworkStatusCode = [noteObject rs_currentReachabilityStatus];
                                                          
                                                          if (old != mNetworkStatusCode)
                                                          {
                                                              aDelegate->onNetworkTechnologyChanged();
                                                          }
                                                      }
                                                  }];
    
    mNativeHandle = (void*)CFBridgingRetain(observer);
    
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    NSLog(@"Current Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
    
    id telObserver = [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *note)
    {
        mDelegate->onCelluarStandardChanged();
        NSLog(@"New Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
    }];
    
    mNativeTelephonyHandle = (void*)CFBridgingRetain(telObserver);
    
    
    NSNumber* val = [[NSUserDefaults standardUserDefaults] objectForKey:@"initguard_key_rssdk"];
    if (![val boolValue])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"initguard_key_rssdk"];
        aDelegate->onFirstInit();
    }
}

NativeNetworkEventsHandler::~NativeNetworkEventsHandler()
{
    id obs = (id)CFBridgingRelease(mNativeHandle);
    [[NSNotificationCenter defaultCenter] removeObserver:obs];
    
    id obsTel = (id)CFBridgingRelease(mNativeTelephonyHandle);
    [[NSNotificationCenter defaultCenter] removeObserver:obsTel];
}












