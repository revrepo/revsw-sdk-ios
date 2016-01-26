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

#ifndef DebugUsageTracker_hpp
#define DebugUsageTracker_hpp

#include <stdio.h>
#include <memory>
#include <string>
#include <map>
#include "Data.hpp"
#include <vector>

namespace rs
{
    class Response;
    class Error;
    struct AvailabilityTestResult;
    
    class DebugUsageTracker final
    {
        size_t mNumberOfConfigurationPulls;
        size_t mNumberOfStatRecordsSubmitted;
        
        Data mMostRecentConfiguration;
        
        size_t mNumberOfRequestsServedViaOrigin;
        size_t mNumberOfRequestsServedViaRev;
        
        size_t mNumberOfBytesServedViaOrigin;
        size_t mNumberOfBytesServedViaRev;
        
        size_t mNumberOfRequestsFailedViaOrigin;
        size_t mNumberOfRequestsFailedViaRev;
        
        size_t mNumberOfSuccessfulQUICRequests;
        size_t mNumberOfFailedQUICRequests;
        
        size_t mNumberOfSuccessfulStandartRequests;
        size_t mNumberOfFailedStandartRequests;
        
        bool mStandartProtocolAvailable;
        bool mQUICProtocolAvailable;
        
        size_t mFailedStatsUploads;
        size_t mFailedConfigurationFetches;
        
    public:
        
        using Statistics = std::map<std::string, std::string>;
        
        DebugUsageTracker();
        ~DebugUsageTracker();
        
        void trackConfigurationPulled(const Data&);
        void trackStatsReported();
        void trackRequest(bool usingRevHost, int64_t, const Response&, const Error&);
        void trackRequestFinished(bool usingRevHost, int64_t, const Response&);
        void trackRequestFailed(bool usingRevHost, int64_t, const Error&);
        
        void QUICRequestsFinishedWithSuccess();
        void QUICRequestsFinishedWithError();
        
        void statsUploadFinishedWithError();
        void configurationFinishedLoadWithError();
        
        void availableProtocols(std::vector<AvailabilityTestResult> aProtocols);
        
        Statistics getUsageStatistics() const;
        std::string getLatestConfiguration() const;
        
        void reset();
    };
}

#endif /* DebugUsageTracker_hpp */
