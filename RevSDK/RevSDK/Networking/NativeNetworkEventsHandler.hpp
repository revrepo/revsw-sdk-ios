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

#pragma once

#include "Timer.hpp"

namespace rs
{
    class INetworkEventsDelegate
    {
    public:
        virtual void onNetworkTechnologyChanged() = 0;
        virtual void onCelluarStandardChanged() = 0;
        virtual void onSSIDChanged() = 0;
        virtual void onFirstInit() = 0;
    };
    
    
    class NativeNetworkEventsHandler
    {
    private:
        INetworkEventsDelegate* mDelegate;
        
        void* mNativeHandle;
        void* mNativeTelephonyHandle;
        
        int mNetworkStatusCode;
        
        std::unique_ptr<Timer>         mSSIDCheckTimer;
        
        std::string mSSID;
        
    public:
        NativeNetworkEventsHandler(INetworkEventsDelegate* aDelegate);
        
        bool isInitialized();
        
        NativeNetworkEventsHandler(const NativeNetworkEventsHandler& aOther) = delete;
        
        ~NativeNetworkEventsHandler();
    };
}
