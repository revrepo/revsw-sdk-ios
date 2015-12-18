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

#import "Utils.hpp"

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
        
      std::string mSDKKey;
       
      StatsHandler* mStatsHandler;
      Timer* mConfigurationRefreshTimer;
      Timer* mStatsReportingTimer;
      Network* mNetwork;
      DataStorage* mDataStorage;
      std::shared_ptr<Configuration> mConfiguration;
        
      RSOperationModeInner mCurrentOperationMode;
      std::vector<std::string> mSpareDomainsWhiteList; // used for switching between white-list and non-white-list options
        
      void reportStats();
        
      void loadConfiguration();
      void applyConfiguration(const Configuration&, bool);
        
      void scheduleTimer(Timer*&, int, std::function<void()>);
      void disableTimer(Timer*&);
        
      public:
        
        Model();
        ~Model();
        
        static Model* instance();
        
        std::shared_ptr<Protocol> currentProtocol();
        std::shared_ptr<Connection> currentConnection();
        std::string SDKKey()const { return mSDKKey; };
        std::string edgeHost()const;
        
        void initialize(std::string aSDKKey);
        
        void setOperationMode(const RSOperationModeInner& aOperationMode);
        RSOperationModeInner currentOperationMode()const;
        
        bool canTransport()const;
        void switchWhiteListOption(bool aOn);
        bool shouldTransportDomainName(std::string aDomainName);
        bool isDomainNameProvisioned(std::string aDomainName);
        
        void addRequestData(const Data &);
        
        bool shouldCollectRequestsData()const;
    };
}

#endif /* Model_hpp */
