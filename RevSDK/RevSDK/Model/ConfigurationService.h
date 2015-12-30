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
#include "Configuration.hpp"

namespace rs
{
    class Network;
    class IConfvigServDelegate
    {
    public:
        virtual void applyConfiguration(std::shared_ptr<const Configuration> aNewConfiguration) = 0;
    };
    
    class ConfigurationService
    {
    private:
        typedef std::chrono::time_point<std::chrono::system_clock> tSpan;
        
        std::mutex mTimeLock;
        
        std::shared_ptr<Configuration> mActiveConfiguration; 
        std::shared_ptr<Configuration> mStaleConfiguration;
        
        std::unique_ptr<Timer>         mConfigurationRefreshTimer;
        
        std::atomic<bool> mUpdateEnabledFlag;
        
        std::unique_ptr<Network> mNetwork;
        
        IConfvigServDelegate* mDelegate;
        
        void loadConfiguration();
        
        bool isStale() const;
        
        std::atomic<tSpan> mLastUpdated;
        
    public:
        ConfigurationService(IConfvigServDelegate* aDelegate);
        
        void setOperationMode(RSOperationModeInner aMode);
        
        void init();
        
        void stopUpdate();
        void resumeUpdate();
        
        std::shared_ptr<const Configuration> getActive() const;
    };
}
