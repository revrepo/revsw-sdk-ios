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
        mFirstByteReceivedTimestamp = std::chrono::milliseconds(std::time(NULL)).count();
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
    
    mStartTimestamp = std::chrono::milliseconds(std::time(NULL)).count();
}

void rs::Connection::onEnd()
{
    assert(!mEndTimestamp);
    
    mEndTimestamp = std::chrono::milliseconds(std::time(NULL)).count();
}










