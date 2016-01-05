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

#include "DebugUsageTracker.hpp"
#include "Error.hpp"
#include "Response.hpp"
#include "RSUtils.h"

using namespace rs;

DebugUsageTracker::DebugUsageTracker() :
mNumberOfConfigurationPulls(0),
mNumberOfStatRecordsSubmitted(0),
mMostRecentConfiguration(),
mNumberOfRequestsServedViaOrigin(0),
mNumberOfRequestsServedViaRev(0),
mNumberOfBytesServedViaOrigin(0),
mNumberOfBytesServedViaRev(0),
mNumberOfRequestsFailedViaOrigin(0),
mNumberOfRequestsFailedViaRev(0)
{
}

DebugUsageTracker::~DebugUsageTracker()
{
}

void DebugUsageTracker::trackConfigurationPulled(const Data& aData)
{
    if (aData.length() > 0)
    {
        mMostRecentConfiguration = aData;
        mNumberOfConfigurationPulls++;
    }
}

void DebugUsageTracker::trackStatsReported()
{
    mNumberOfStatRecordsSubmitted++;
}

void DebugUsageTracker::trackRequest(bool usingRevHost,
                                     int64_t aDataLength,
                                     const Response& aResponse,
                                     const Error& aError)
{
    if (aError.isNoError()) {
        trackRequestFinished(usingRevHost, aDataLength, aResponse);
    } else {
        trackRequestFailed(usingRevHost, aDataLength, aError);
    }
}

void DebugUsageTracker::trackRequestFinished(bool usingRevHost,
                                             int64_t aDataLength,
                                             const Response& aResponse)
{
    if (usingRevHost) {
        mNumberOfBytesServedViaRev += aDataLength;
        mNumberOfRequestsServedViaRev++;
    } else {
        mNumberOfBytesServedViaOrigin += aDataLength;
        mNumberOfRequestsServedViaOrigin++;
    }
}

void DebugUsageTracker::trackRequestFailed(bool usingRevHost,
                                           int64_t aDataLength,
                                           const Error& aError)
{
    if (usingRevHost) {
        mNumberOfBytesServedViaRev += aDataLength;
        mNumberOfRequestsFailedViaRev++;
    } else {
        mNumberOfBytesServedViaOrigin += aDataLength;
        mNumberOfRequestsFailedViaOrigin++;
    }
}

DebugUsageTracker::Statistics DebugUsageTracker::getUsageStatistics() const
{
    std::map<std::string, std::string> stats;
    
    stats["Number of configuration pulls"]          = std::to_string(mNumberOfConfigurationPulls);
    stats["Number of stat records submitted"]       = std::to_string(mNumberOfStatRecordsSubmitted);
    
    stats["Number of requests served via origin"]   = std::to_string(mNumberOfRequestsServedViaOrigin);
    stats["Number of requests served via Rev"]      = std::to_string(mNumberOfRequestsServedViaRev);

    stats["Number of requests failed via origin"]   = std::to_string(mNumberOfRequestsFailedViaOrigin);
    stats["Number of requests failed via Rev"]      = std::to_string(mNumberOfRequestsFailedViaRev);

    stats["Kbytes served via origin"]               = std::to_string(mNumberOfBytesServedViaOrigin / 1024);
    stats["Kbytes served via Rev"]                  = std::to_string(mNumberOfBytesServedViaRev / 1024);
    
    return stats;
}

std::string DebugUsageTracker::getLatestConfiguration() const
{
    return mMostRecentConfiguration.toString();
}

void DebugUsageTracker::reset()
{
    mNumberOfConfigurationPulls = 0;
    mNumberOfStatRecordsSubmitted = 0;
    mNumberOfRequestsServedViaOrigin = 0;
    mNumberOfRequestsServedViaRev = 0;
    mNumberOfBytesServedViaOrigin = 0;
    mNumberOfBytesServedViaRev = 0;
    mNumberOfRequestsFailedViaOrigin = 0;
    mNumberOfRequestsFailedViaRev = 0;
}
