//
//  Model.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <mutex>
#include <map>
#include <algorithm>

#include "Model.hpp"
#include "StandardProtocol.hpp"
#include "QUICProtocol.hpp"
#include "StandardConnection.hpp"
#include "QUICConnection.hpp"
#include "RSUtilsBridge.hpp"
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
        mConfigurationRefreshTimer = nullptr;
        mNetwork                   = new Network;
        mDataStorage               = new DataStorage;
        mSpareDomainsWhiteList     = std::vector<std::string>();
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
        
            {httpsProtocolName(), Connection::create<StandardConnection>() }
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
            
           if (aError.code == noErrorCode())
           {
              Configuration configuration = ConfigurationProcessor::processConfigurationData(aData);
              mDataStorage->saveConfiguration(configuration);
              mConfiguration = std::make_shared<Configuration>(configuration);
               
               
              if (!mConfigurationRefreshTimer)
              {
                  std::function<void()> scheduledFunction = [this](){
                  
                      loadConfiguration();
                  };
                  
                  mConfigurationRefreshTimer = new Timer(mConfiguration.get()->refreshInterval, scheduledFunction);
                  mConfigurationRefreshTimer->start();
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
    
    void Model::setOperationMode(const RSOperationModeInner& aOperationMode)
    {
        mCurrentOperationMode = aOperationMode;
    }
    
    RSOperationModeInner Model::currentOperationMode() const
    {
        return mCurrentOperationMode;
    }
    
    bool Model::canTransport()const
    {
        return mCurrentOperationMode == kRSOperationModeInnerTransport || mCurrentOperationMode == kRSOperationModeInnerTransportAndReport;
    }
    
    void Model::switchWhiteListOption(bool aOn)
    {
       if (aOn)
       {
           mConfiguration->domainsWhiteList = mSpareDomainsWhiteList;
       }
       else
       {
           mSpareDomainsWhiteList = mConfiguration->domainsWhiteList;
           mConfiguration->domainsWhiteList.clear();
       }
    }
    
    bool Model::shouldTransportDomainName(std::string aDomainName)
    {
        if (!canTransport())
        {
            return false;
        }
        
        auto begin = mConfiguration->domainsBlackList.begin();
        auto end   = mConfiguration->domainsBlackList.end();
        
        if (std::find(begin, end, aDomainName) != end)
        {
            return false;
        }
        
        begin = mConfiguration->domainsWhiteList.begin();
        end   = mConfiguration->domainsWhiteList.end();
        
        if (std::find(begin, end, aDomainName) != end)
        {
            return true;
        }

        return mConfiguration->domainsWhiteList.empty();
    }
}