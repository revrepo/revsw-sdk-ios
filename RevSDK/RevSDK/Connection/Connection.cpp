//
//  Connection.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//
#include <assert.h>
#include <iostream>
#include <chrono>
#include <ctime>
#include "Connection.hpp"

std::atomic<int> rs::Connection::gLastConnectionID(0);

rs::Connection::Connection() : mConnectionID(gLastConnectionID),
mBytesSent(0),
mBytesReceived(0),
mStartTimestamp(0),
mEndTimestamp(0),
mFirstByteReceivedTimestamp(0)
{
    gLastConnectionID++;
}

void rs::Connection::addSentBytesCount(long long aCount)
{
    if (0 == mBytesSent)
    {
        int64_t milliseconds_since_epoch = std::chrono::system_clock::now().time_since_epoch() / std::chrono::milliseconds(1); 
        mFirstByteReceivedTimestamp = milliseconds_since_epoch;
    }
    mBytesSent += aCount;
}
void rs::Connection::addReceivedBytesCount(long long aCount)
{
    mBytesReceived += aCount;
}

void rs::Connection::onStart()
{
    assert(!mStartTimestamp);
    
    int64_t milliseconds_since_epoch = std::chrono::system_clock::now().time_since_epoch() / std::chrono::milliseconds(1);
    
    mStartTimestamp = milliseconds_since_epoch;
}

void rs::Connection::onEnd()
{
    assert(!mEndTimestamp);
    
    int64_t milliseconds_since_epoch = std::chrono::system_clock::now().time_since_epoch() / std::chrono::milliseconds(1);
    mEndTimestamp = milliseconds_since_epoch;
}










