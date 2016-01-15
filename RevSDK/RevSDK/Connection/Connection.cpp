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

#include <assert.h>
#include <iostream>
#include <chrono>
#include <ctime>
#include "Connection.hpp"

std::atomic<int> rs::Connection::gLastConnectionID(1);

rs::Connection::Connection() : mConnectionID(gLastConnectionID++),
mBytesSent(0),
mBytesReceived(0),
mStartTimestamp(0),
mEndTimestamp(0),
mFirstByteReceivedTimestamp(0)
{
}

void rs::Connection::addSentBytesCount(long long aCount)
{
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

void rs::Connection::onResponseReceived()
{
    int64_t milliseconds_since_epoch = std::chrono::system_clock::now().time_since_epoch() / std::chrono::milliseconds(1);
    mFirstByteReceivedTimestamp = milliseconds_since_epoch;
}

int rs::Connection:: getLastConnectionId()
{
    int lastConnectionId = gLastConnectionID++;
    
    return lastConnectionId;
}

std::string rs::Connection::edgeHost() const
{
    return mEdgeHost;
}
