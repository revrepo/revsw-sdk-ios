//
//  RSUDPService.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/6/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#pragma once

#include <functional>
#include <thread>
#include <mutex>
#include <vector>

#include "RSUDPSocket.h"
#include "Data.hpp"

namespace rs
{
    class UDPService
    {
    private:
        struct Info
        {
            std::string host;
            int port;
            std::function<void(UDPService*)> handler;
            std::thread* thread;
        };
        typedef std::vector<std::function<void(void)>> FuncList;
    private:
        UDPService(const Info& aInfo);
        ~UDPService();
    public:
        static void dispatch(const std::string& aHost, int aPort, std::function<void(UDPService*)> aHandler);
        
        void setOnRecv(std::function<void(UDPService*,const void*, size_t)> aOnRecv) { mOnRecv = aOnRecv; }
        void setOnError(std::function<void(UDPService*, int, std::string)> aOnError) { mOnError = aOnError; }
        void setOnIdle(std::function<void(size_t)> aOnIdle) { mOnIdle = aOnIdle; }
        bool send(const void*, size_t, bool* aSyncAndOk = nullptr);
        void perform(std::function<void(void)> aFunc, bool aForceAsync);
        
        bool connected() const;
        
        void shutdown();
        
    private:
        static void threadFunc(void*);
        void run();
        bool p_properThread() const;
    private:
        std::thread* mThread;
        std::thread::native_handle_type mThreadId;
        UDPSocket* mSocket;
        unsigned long long mTimeMS;
        std::string mHost;
        int mPort;
        std::function<void(UDPService*)> mHandler;
        std::function<void(UDPService*,const void*, size_t)> mOnRecv;
        std::function<void(UDPService*, int, std::string)> mOnError;
        std::function<void(size_t)> mOnIdle;
        std::vector<char> mBuffer;
        
        Data::List mQueue;
        std::mutex mQueueLock;
        
        FuncList mCalls;
        std::mutex mCallsLock;
        
        bool mFirstConnect;
        bool mCloseFlag;
        int mId;
    };
}