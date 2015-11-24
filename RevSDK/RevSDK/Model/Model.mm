//
//  Model.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <mutex>
#include <map>

#include "Model.hpp"
#include "StandardProtocol.hpp"
#include "QUICProtocol.hpp"
#include "StandardConnection.hpp"
#include "QUICConnection.hpp"
#include "RSUtils.h"
#include "Network.hpp"
#include "Data.hpp"
#include "Error.hpp"
#include "ConfigurationProcessor.hpp"
#include "Configuration.hpp"
#include "DataStorage.hpp"
#include "Timer.hpp"

namespace rs
{
    Model::Model()
    {
        configurationRefreshTimer = nullptr;
        mNetwork                  = new Network;
        mDataStorage              = new DataStorage;
    }
    
    Model* Model::instance()
    {
        static std::mutex mtx;
        static Model* _instance = nullptr;
        
        if (!_instance)
        {
            mtx.lock();
            _instance = new Model;
            mtx.unlock();
        }
        
        return _instance;
    }
    
    std::shared_ptr<Protocol>  Model::currentProtocol()
    {
        return std::make_shared<StandardProtocol>();
    }
    
    std::shared_ptr<Connection> Model::currentConnection()
    {
        std::map<std::string, std::shared_ptr<Connection>> connectionDictionary = {
        
            {kRSHTTPSProtocolName, Connection::create<StandardConnection>() }
        };

        std::shared_ptr<Protocol> protocol     = currentProtocol();
        std::string protocolName               = protocol.get()->protocolName();
        std::shared_ptr<Connection> connection = connectionDictionary[protocolName];
        
        return connection;
    }
    
    void Model::loadConfiguration()
    {
        Configuration configuration = mDataStorage->configuration();
        mConfiguration = std::make_shared<Configuration>(configuration);
        
        std::function<void(const Data&, const Error&)> completionBlock = [this](const Data& aData, const Error& aError){
            
           if (aError.code == kRSNoErrorCode)
           {
              Configuration configuration = ConfigurationProcessor::processConfigurationData(aData);
              mDataStorage->saveConfiguration(configuration);
              mConfiguration = std::make_shared<Configuration>(configuration);
               
              if (!configurationRefreshTimer)
              {
                  std::function<void()> scheduledFunction = [this](){
                  
                      loadConfiguration();
                  };
                  
                  configurationRefreshTimer = new Timer(mConfiguration.get()->refreshInterval, scheduledFunction);
                  configurationRefreshTimer->start();
              }
           }
           else
           {
               std::cout << "\n" << "RevSDK failed to load configuration " << aError.description();
           }
        };
        
        mNetwork->loadConfigurationWithCompletionBlock(completionBlock);
    }
    
    void Model::initialize()
    {
        loadConfiguration();
    }
}