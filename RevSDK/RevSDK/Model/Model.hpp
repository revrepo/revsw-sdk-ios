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

#ifdef DEBUG
#define RS_ENABLE_DEBUG_LOGGING
#endif


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
    
    class Model : IConfvigServDelegate
    {
    private:
        std::mutex mLock;
        std::string mSDKKey;
       
        std::unique_ptr<StatsHandler> mStatsHandler;
        
        std::unique_ptr<Timer> mStatsReportingTimer;
        
        Network mNetwork;
        
        //std::shared_ptr<Configuration> mConfiguration;
        std::unique_ptr<ConfigurationService> mConfService;
        
        std::vector<std::string> mSpareDomainsWhiteList; // used for switching between white-list and non-white-list options
        
        void reportStats();
        
      public:
        
        Model();
        ~Model();
        
        void applyConfiguration(std::shared_ptr<const Configuration> aConfiguration) override;
        
        static Model* instance();
        
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
        
        void stopConfigurationUpdate();
        void resumeConfigurationUpdate();
        
        bool shouldCollectRequestsData();
    };
}

#endif /* Model_hpp */
