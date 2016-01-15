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

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#include "RSSystemInfo.h"

#include "RSUtils.h"
#include "Utils.hpp"

#include "NativeNetworkEventsHandler.hpp"

#include "RSReachability.h"

using namespace rs;

const int kRefreshIntervalSec = 3;

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
    
    id telObserver = [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *note)
    {
        mDelegate->onCelluarStandardChanged(); 
    }];
    
    mSSID = stdStringFromNSString([RSSystemInfo ssid]);
    /////////////////////
    Timer::scheduleTimer(mSSIDCheckTimer, kRefreshIntervalSec, [this]{
        
        const std::string str = stdStringFromNSString([RSSystemInfo ssid]);
        
        if (str != mSSID && "" != mSSID)
        {
            mDelegate->onSSIDChanged();
        }
        mSSID = str;
    });
    ////////////////////
    
    
    mNativeTelephonyHandle = (void*)CFBridgingRetain(telObserver);
}

NativeNetworkEventsHandler::~NativeNetworkEventsHandler()
{
    id obs = (id)CFBridgingRelease(mNativeHandle);
    [[NSNotificationCenter defaultCenter] removeObserver:obs];
    
    id obsTel = (id)CFBridgingRelease(mNativeTelephonyHandle);
    [[NSNotificationCenter defaultCenter] removeObserver:obsTel];
}

bool NativeNetworkEventsHandler::isInitialized()
{
    NSNumber* val = [[NSUserDefaults standardUserDefaults] objectForKey:@"initguard_key_rssdk"];
    if (![val boolValue])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"initguard_key_rssdk"];
        return false;
    }
    return true;
}










