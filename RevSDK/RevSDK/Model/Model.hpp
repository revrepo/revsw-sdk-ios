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
    
    class Model : public IConfvigServDelegate
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
        
        std::unique_ptr<IConfigurationService> mConfService;
        //std::unique_ptr<IConfigurationService> mCachedConfService;
        
        std::vector<std::string> mSpareDomainsWhiteList; // used for switching between white-list and non-white-list options
        
        void reportStats();
        
        Log::Target::Ref mMemoryLog;
        
      public:
        
        Model();
        ~Model();
        
        void applyConfiguration(std::shared_ptr<const Configuration> aConfiguration) override;
        
        std::vector<std::string> getAllowedProtocolIDs() const;
        
        static Model* instance();
        
        std::shared_ptr<DebugUsageTracker> debug_usageTracker() const;
        void debug_forceReloadConfiguration();
        
        std::shared_ptr<Protocol> currentProtocol();
        std::shared_ptr<Connection> currentConnection();
        std::string SDKKey()const { return mSDKKey; };
        std::string edgeHost();
        
        void initialize(std::string aSDKKey);
        
        RSOperationModeInner currentOperationMode();
         
        void setOperationMode(const RSOperationModeInner& aOperationMode);
        
        bool canTransport();
        //void switchWhiteListOption(bool aOn);
        bool shouldTransportDomainName(std::string aDomainName);
        bool isDomainNameProvisioned(std::string aDomainName);
        
        void addRequestData(const Data &);
        
        void resumeConfigurationUpdate();
        
        bool shouldCollectRequestsData();
        
        //void debug_enableDebugMode();
        void debug_disableDebugMode();
        void debug_replaceConfigurationService(IConfigurationService* aNewService);
        
        LogTarget* log() { return (LogTarget*)mMemoryLog.get(); }
    };
}

#endif /* Model_hpp */
