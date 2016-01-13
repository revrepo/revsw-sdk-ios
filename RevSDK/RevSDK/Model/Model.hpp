//
//  Model.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Model_hpp
#define Model_hpp

#include <stdio.h>
#include <memory>
#include <string>
#include <vector>
#include <functional>

#include <mutex>
#include <atomic>

#import "Utils.hpp"
#include "ConfigurationService.h"
#include "Network.hpp"
#include "JSONUtils.hpp"

#include "ProtocolSelector.hpp"

#ifdef DEBUG
#define RS_ENABLE_DEBUG_LOGGING
#endif

#include "RSLog.h"

//#ifdef DEBUG
//#define RS_DBG_MAXREQESTS 3
//#endif

namespace rs
{
    class Protocol;
    class Connection;
    class Configuration;
    class Timer;
    class Request;
    class Data;
    class StatsHandler;
    class DebugUsageTracker;
    
    class Model : public IConfvigServDelegate, Log::Target
    {
    private:
        RSLogginLevel mCurrentLoggingLevel;
        
        std::mutex mLock;
        std::string mSDKKey;
        
        std::shared_ptr<DebugUsageTracker> mUsageTracker;
       
        std::unique_ptr<StatsHandler> mStatsHandler;
        
        std::unique_ptr<Timer> mStatsReportingTimer;
        
        Network mNetwork;
        ProtocolSelector mProtocolSelector;
        
        std::shared_ptr<IConfigurationService> mConfService;
        //std::unique_ptr<IConfigurationService> mCachedConfService;
        
        std::vector<std::string> mSpareDomainsWhiteList; // used for switching between white-list and non-white-list options
        
        std::function<void(rs::Log::Level, const char*, const char*)> mEventTriggerCallback;
        bool mEventTriggerOn;
        
        void reportStats();
        
        Log::Target::Ref mMemoryLog;
        Log::Target::Ref mProxy;

        void logTargetPrint(Log::Level aLevel, int aTag, const char* aMessage) override;
        
      public:
        
        Model();
        ~Model();
        
        void initializeContent();
        
        void switchEventTrigger(bool aOn, std::function<void(rs::Log::Level, const char*, const char*)> aCallback);
        std::shared_ptr<const Configuration> getActiveConfiguration()const;
        
        void applyConfiguration(std::shared_ptr<const Configuration> aConfiguration) override;
        void scheduleStatsReporting() override;
        
        std::vector<std::string> getAllowedProtocolIDs() const;
        
        static Model* instance();
        
        std::shared_ptr<DebugUsageTracker> debug_usageTracker() const;
        void debug_forceReloadConfiguration();
        
        std::shared_ptr<Protocol> currentProtocol();
        std::shared_ptr<Connection> currentConnection();
        std::shared_ptr<Connection> connectionForProtocolName(const std::string&);
        std::string SDKKey()const { return mSDKKey; };
        std::string edgeHost();
        
        void initialize(std::string aSDKKey);
        
        RSOperationModeInner currentOperationMode();
        
        bool canTransport();
        
        bool shouldTransportDomainName(std::string aDomainName);
        bool isDomainNameProvisioned(std::string aDomainName);
        
        void addRequestData(const Data &);
        
        void resumeConfigurationUpdate();
        
        bool shouldCollectRequestsData();
        
        void debug_disableDebugMode();
        void debug_replaceConfigurationService(IConfigurationService* aNewService);
        
        bool debug_isConfigurationStale();
        
        LogTarget* log() { return (LogTarget*)mMemoryLog.get(); }
        
        void addEvent(const std::string&, const int, const std::string& , const float, RSLogginLevel);
    };
}

#endif /* Model_hpp */
