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

#ifdef DEBUG
#define RS_ENABLE_DEBUG_LOGGING
#endif

namespace rs
{
    class Protocol;
    class Connection;
    class Network;
    class DataStorage;
    class Configuration;
    class Timer;
    class Request;
    class Data;
    class StatsHandler;
    
    class Model
    {
    private:
        std::mutex mLock;
        std::atomic<bool> mUpdateEnabledFlag;
        std::string mSDKKey;
       
        std::unique_ptr<StatsHandler> mStatsHandler;
        
        std::unique_ptr<Timer> mConfigurationRefreshTimer;
        std::unique_ptr<Timer> mStatsReportingTimer;
        std::unique_ptr<Network> mNetwork;
        
        std::shared_ptr<DataStorage> mDataStorage;
        
        std::unique_ptr<Configuration> mCachedConfiguration;
        std::shared_ptr<Configuration> mConfiguration;
        
        RSOperationModeInner mCurrentOperationMode;
        std::vector<std::string> mSpareDomainsWhiteList; // used for switching between white-list and non-white-list options
        
        void reportStats();
        
        void loadConfiguration();
        void applyConfiguration(const Configuration&, bool);
        
        void scheduleTimer(std::unique_ptr<Timer>&, int, std::function<void()>);
        void disableTimer(std::unique_ptr<Timer>&);
        
      public:
        
        Model();
        ~Model();
        
        static Model* instance();
        
        std::shared_ptr<Protocol> currentProtocol();
        std::shared_ptr<Connection> currentConnection();
        std::string SDKKey()const { return mSDKKey; };
        std::string edgeHost();
        
        void initialize(std::string aSDKKey);
        
        RSOperationModeInner currentOperationMode();
         
        void setOperationMode(const RSOperationModeInner& aOperationMode);
        
        bool canTransport();
        void switchWhiteListOption(bool aOn);
        bool shouldTransportDomainName(std::string aDomainName);
        bool isDomainNameProvisioned(std::string aDomainName);
        
        void addRequestData(const Data &);
        
        void stopConfigurationUpdate();
        void resumeConfigurationUpdate();
        
        bool shouldCollectRequestsData();
    };
}

#endif /* Model_hpp */
