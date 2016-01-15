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

#include <vector>
#include <memory>
#include <chrono>

#include "Utils.hpp"

#include "DataStorage.hpp"
#include "Timer.hpp"

#include "IConfigurationService.h"
#include "LeakDetector.h"

namespace rs
{
    class Network;
    class IConfvigServDelegate
    {
    public:
        virtual void applyConfiguration(std::shared_ptr<const Configuration> aNewConfiguration) = 0;
        virtual void scheduleStatsReporting() = 0;
    };
    
    class ConfigurationService : public IConfigurationService
    {
        REV_LEAK_DETECTOR(ConfigurationService);
        
        bool mStaleOnFlag;
        typedef std::chrono::time_point<std::chrono::system_clock> tSpan;
        
        std::mutex mTimeLock;
        
        std::shared_ptr<Configuration> mActiveConfiguration; 
        std::shared_ptr<Configuration> mStaleConfiguration;
        
        std::unique_ptr<Timer>         mConfigurationRefreshTimer;
        
        std::unique_ptr<Network> mNetwork;
        
        std::function<bool()> cbAdditionalStaleCondition;
        
        IConfvigServDelegate* mDelegate;
        
        void loadConfiguration();
        
        bool isTimedOut() const;
        
        
        std::atomic<tSpan> mLastUpdated;
        
        std::function<void()> mStaleCallback;
        
    public:
        ConfigurationService(IConfvigServDelegate* aDelegate, std::function<bool()> fExternalStaleCondition, std::function<void()> aStaleCallback);
        virtual ~ConfigurationService();
        
        void setOperationMode(RSOperationModeInner aMode) override;
        
        bool isStale() const override;
        
        void init() override;
        
        void stopUpdate() override;
        void resumeUpdate() override;
        
        std::shared_ptr<const Configuration> getActive() override;
    };
}
