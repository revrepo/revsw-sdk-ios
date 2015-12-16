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
#include "Request.hpp"

namespace rs
{
    Model::Model()
    {
        mStatsReportingTimer       = nullptr;
        mConfigurationRefreshTimer = nullptr;
        mNetwork                   = new Network;
        mDataStorage               = new DataStorage;
        mSpareDomainsWhiteList     = std::vector<std::string>();
        mTestPassOption            = false;
    }
    
    Model::~Model()
    {
        delete mNetwork;
        delete mDataStorage;
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
    
    std::string Model::edgeHost() const
    {
        return mConfiguration->edgeHost;
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
               saveConfiguration(aData);
               startTimers();
           }
           else
           {
               std::cout << "\n" << "RevSDK failed to load configuration " << aError.description();
           }
        };
        
        const std::string kConfigurationEndPoint = "sdk/config";
        std::string URL                          = "http://" + edgeHost() + "/" + kConfigurationEndPoint;
        mNetwork->performRequest(URL, completionBlock);
    }
    
    void Model::saveConfiguration(const Data& aConfigurationData)
    {
        Configuration configuration = ConfigurationProcessor::processConfigurationData(aConfigurationData);
        mDataStorage->saveConfiguration(configuration);
        mConfiguration = std::make_shared<Configuration>(configuration);
    }
    
    void Model::scheduleTimer(Timer*& aTimer, int aInterval, std::function<void()> aFunction)
    {
        aTimer = new Timer(aInterval, aFunction);
        aTimer->start();
    }
    
    void Model::reportStats()
    {
        
    }
    
    void Model::startTimers()
    {
        if (!mConfigurationRefreshTimer)
        {
            std::function<void()> scheduledFunction = std::bind(&Model::loadConfiguration, this);
            scheduleTimer(mConfigurationRefreshTimer, mConfiguration.get()->refreshInterval, scheduledFunction);
        }
        
        if (!mStatsReportingTimer)
        {
            std::function<void()> scheduledFunction = std::bind(&Model::reportStats, this);
            scheduleTimer(mStatsReportingTimer, mConfiguration.get()->statsReportingInterval, scheduledFunction);
        }
    }
    
    void Model::initialize(std::string aSDKKey)
    {
        mSDKKey = aSDKKey;
        setOperationMode(rs::kRSOperationModeInnerTransportAndReport);
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
        if (mTestPassOption)
        {
            return true;
        }
        
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
        
        begin = mConfiguration->domainsProvisionedList.begin();
        end   = mConfiguration->domainsProvisionedList.end();
        
        if (std::find(begin, end, aDomainName) != end)
        {
            return true;
        }
        
        begin = mConfiguration->domainsWhiteList.begin();
        end   = mConfiguration->domainsWhiteList.end();
        
        if (std::find(begin, end, aDomainName) != end)
        {
            return true;
        }
        
        return mConfiguration->domainsWhiteList.empty();
    }
    
    bool Model::isDomainNameProvisioned(std::string aDomainName)
    {
        auto begin = mConfiguration->domainsProvisionedList.begin();
        auto end   = mConfiguration->domainsProvisionedList.end();
        return std::find(begin, end, aDomainName) != end;
    }
}