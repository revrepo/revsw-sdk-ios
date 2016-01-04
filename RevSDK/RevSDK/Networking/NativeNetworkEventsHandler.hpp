//
//  NativeNetworkEventsHandler.hpp
//  RevSDK
//
//  Created by Vlad Joss on 04.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#pragma once


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
        
    public:
        NativeNetworkEventsHandler(INetworkEventsDelegate* aDelegate);
        
        NativeNetworkEventsHandler(const NativeNetworkEventsHandler& aOther) = delete;
        
        ~NativeNetworkEventsHandler();
    };
}
