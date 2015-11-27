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

namespace rs
{
    typedef enum
    {
        kRSOperationModeInnerOff,
        kRSOperationModeInnerTransport,
        kRSOperationModeInnerReport,
        kRSOperationModeInnerTransportAndReport
    }RSOperationModeInner;
    
    class Protocol;
    class Connection;
    class Network;
    class DataStorage;
    class Configuration;
    class Timer;
    class Request;
    
    class Model
    {
        
      std::string mSDKKey;
        
      Timer* mConfigurationRefreshTimer;
      Network* mNetwork;
      DataStorage* mDataStorage;
      std::shared_ptr<Configuration> mConfiguration;
        
      RSOperationModeInner mCurrentOperationMode;
      std::vector<std::string> mSpareDomainsWhiteList; // used for switching between white-list and non-white-list options
        
      public:
        
        Model();
        
        static Model* instance();
        
        std::shared_ptr<Protocol> currentProtocol();
        std::shared_ptr<Connection> currentConnection();
        std::string SDKKey()const { return mSDKKey; };
        std::string edgeHost()const;
        
        void loadConfiguration();
        void initialize(std::string aSDKKey);
        
        void setOperationMode(const RSOperationModeInner& aOperationMode);
        RSOperationModeInner currentOperationMode()const;
        
        bool canTransport()const;
        void switchWhiteListOption(bool aOn);
        bool shouldTransportDomainName(std::string aDomainName);
        bool isDomainNameProvisioned(std::string aDomainName);
    };
}

#endif /* Model_hpp */
