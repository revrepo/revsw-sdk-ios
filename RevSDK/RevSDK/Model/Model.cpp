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
#include "StatsHandler.hpp"

#define RSStartTimer(aFunc, aTimer, aInterval)\
        do{\
             if (!aTimer)\
             {\
                std::function<void()> scheduledFunction = std::bind(aFunc, this);\
                scheduleTimer(mStatsReportingTimer, aInterval, scheduledFunction);\
             }\
        }while(0)

namespace rs
{
    Model::Model()
    {
        mStatsHandler              = new StatsHandler;
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
        delete mStatsHandler;
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
               RSStartTimer(&Model::loadConfiguration, mConfigurationRefreshTimer, mConfiguration->refreshInterval);
           }
           else
           {
               std::cout << "\n" << "RevSDK failed to load configuration " << aError.description();
           }
        };
        
        mNetwork->loadConfiguration(completionBlock);
    }
    
    void Model::saveConfiguration(const Data& aConfigurationData)
    {
        Configuration configuration = ConfigurationProcessor::processConfigurationData(aConfigurationData);
        setOperationMode(configuration.operationMode);
        mDataStorage->saveConfiguration(configuration);
        mStatsHandler->setReportingLevel(configuration.statsReportingLevel);
        mConfiguration = std::make_shared<Configuration>(configuration);
    }
    
    void Model::scheduleTimer(Timer*& aTimer, int aInterval, std::function<void()> aFunction)
    {
        aTimer = new Timer(aInterval, aFunction);
        aTimer->start();
    }
    
    void Model::disableTimer(Timer*& aTimer)
    {
        if (aTimer)
        {
            aTimer->invalidate();
            delete aTimer;
            aTimer = nullptr;
        }
    }
    
    void Model::reportStats()
    {
        std::function<void(const Error& )> completion = [=](const Error& aError){
        
            std::cout << "Stats reported " << aError.description()  << std::endl;
        };
        
        Data statsData = mStatsHandler->getStatsData();
        mNetwork->sendStats(statsData, completion);
    }
    
    void Model::initialize(std::string aSDKKey)
    {
        mSDKKey = aSDKKey;
        loadConfiguration();
    }
    
    void Model::setOperationMode(const RSOperationModeInner& aOperationMode)
    {
        mCurrentOperationMode = aOperationMode;
        
        if (mCurrentOperationMode == kRSOperationModeInnerReport ||
            mCurrentOperationMode == kRSOperationModeInnerTransportAndReport)
        {
            RSStartTimer(&Model::reportStats, mStatsReportingTimer, mConfiguration->statsReportingInterval);
        }
        else
        {
            disableTimer(mStatsReportingTimer);
        }
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