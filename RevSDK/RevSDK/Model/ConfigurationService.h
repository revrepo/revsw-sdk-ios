//
//  ConfigurationService.hpp
//  RevSDK
//
//  Created by Vlad Joss on 30.12.15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#pragma once 

#include <vector>
#include <memory>
#include <chrono>

#include "Utils.hpp"

#include "DataStorage.hpp"
#include "Timer.hpp"

#include "IConfigurationService.h"

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
    private:
        
        bool mStaleOnFlag;
        typedef std::chrono::time_point<std::chrono::system_clock> tSpan;
        
        std::mutex mTimeLock;
        
        std::shared_ptr<Configuration> mActiveConfiguration; 
        std::shared_ptr<Configuration> mStaleConfiguration;
        
        std::unique_ptr<Timer>         mConfigurationRefreshTimer;
        
        std::atomic<bool> mUpdateEnabledFlag;
        
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
