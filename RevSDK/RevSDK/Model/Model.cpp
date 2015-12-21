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
#include "Utils.hpp"
#include "Network.hpp"
#include "Data.hpp"
#include "Error.hpp"
#include "JSONUtils.hpp"
#include "Configuration.hpp"
#include "DataStorage.hpp"
#include "Timer.hpp"
#include "Request.hpp"
#include "StatsHandler.hpp"

#define RSStartTimer(aFunc, aTimer, aInterval)\
        do{\
             if (!aTimer && aInterval > 0)\
             {\
                std::function<void()> scheduledFunction = std::bind(aFunc, this);\
                scheduleTimer(aTimer, aInterval, scheduledFunction);\
             }\
        }while(0)

namespace rs
{
    Model::Model() : mUpdateEnabledFlag(true)
    {
        mConfiguration             = nullptr;
        mStatsReportingTimer       = nullptr;
        mConfigurationRefreshTimer = nullptr;
        mNetwork                   = std::unique_ptr<Network>(new Network);
        mDataStorage               = std::make_shared<DataStorage>();
        mSpareDomainsWhiteList     = std::vector<std::string>();
        mStatsHandler              = std::unique_ptr<StatsHandler>(new StatsHandler(mDataStorage));
        
        Configuration configuration = mDataStorage->configuration();
        
        applyConfiguration(configuration, false);
    }
    
    Model::~Model()
    {
    }
    
    Model* Model::instance()
    {
        static std::mutex mtx;
        static Model* _instance = nullptr;
        
        if (!_instance)
        {
            std::lock_guard<std::mutex> scopedLock(mtx);
            _instance = new Model;
        }
        
        return _instance;
    }
    
    std::string Model::edgeHost()
    {
        std::lock_guard<std::mutex> scopedLock(mLock);
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
        std::function<void(const Data&, const Error&)> completionBlock = [this](const Data& aData, const Error& aError){
            
#ifdef RS_ENABLE_DEBUG_LOGGING
            std::cout << "Configuration loaded\n";
#endif
            
           if (aError.code == noErrorCode())
           {
               Configuration configuration = processConfigurationData(aData);
               applyConfiguration(configuration, true);
               // VJ:double save, error
               //mDataStorage->saveConfiguration(configuration);
               
               RSStartTimer(&Model::loadConfiguration, mConfigurationRefreshTimer, mConfiguration->refreshInterval);
           }
           else
           {
               std::cout << "\n" << "RevSDK failed to load configuration " << aError.description();
           }
        };
        
        mNetwork->loadConfiguration(completionBlock);
    }
    
    void Model::applyConfiguration(const Configuration& aConfiguration, bool aShouldSave)
    {
        bool isUpdateEnabled = mUpdateEnabledFlag.load();
        if (isUpdateEnabled)
        {
            {
                std::lock_guard<std::mutex> lockGuard(mLock);
#ifdef RS_ENABLE_DEBUG_LOGGING
                std::cout<<"Model:: applying new configuretion"<<std::endl;
#endif
                
                mConfiguration = std::make_shared<Configuration>(aConfiguration);
                mStatsHandler->setReportingLevel(aConfiguration.statsReportingLevel);
            }
            setOperationMode(aConfiguration.operationMode);
        }
        
        aShouldSave = aShouldSave || !isUpdateEnabled;
        if (aShouldSave)
        {
            mDataStorage->saveConfiguration(aConfiguration);
        }
    }
    
    void Model::scheduleTimer(std::unique_ptr<Timer>& aTimer, int aInterval, std::function<void()> aFunction)
    {
        aTimer = std::unique_ptr<Timer>(new Timer(aInterval, aFunction));
        aTimer->start();
    }
    
    void Model::disableTimer(std::unique_ptr<Timer>& aTimer)
    {
        if (aTimer)
        {
            aTimer->invalidate();
            //delete aTimer;
            aTimer = nullptr;
        }
    }
    
    void Model::reportStats()
    {
        std::function<void(const Error& )> completion = [=](const Error& aError){
        
           std::cout << "Stats reported" << std::endl;
            
           if (aError.isNoError())
           {
               if (mConfiguration->statsReportingLevel != kRSStatsReportingLevelDeviceData)
               {
                   mStatsHandler->deleteRequestsData();
               }
           }
        };
        
        Data statsData = mStatsHandler->getStatsData();
        mNetwork->sendStats(statsData, completion);
    }
    
    void Model::initialize(std::string aSDKKey)
    {
        std::lock_guard<std::mutex> lockGuard(mLock);
        mSDKKey = aSDKKey;
        loadConfiguration();
    }
    
    void Model::setOperationMode(const RSOperationModeInner& aOperationMode)
    {
        std::lock_guard<std::mutex> scopedLock(mLock);
        
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout<<"Model::setOperationMode __peviousID::"<<mCurrentOperationMode<<" "
        <<"__newID:"<<aOperationMode<<std::endl;
#endif
        
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
    
    RSOperationModeInner Model::currentOperationMode()
    {
        std::lock_guard<std::mutex> scopedLock(mLock);
        return mCurrentOperationMode;
    }
    
    bool Model::canTransport()
    {
        bool flag;
        {
            std::lock_guard<std::mutex> scopedLock(mLock);
            flag = mCurrentOperationMode == kRSOperationModeInnerTransport || mCurrentOperationMode == kRSOperationModeInnerTransportAndReport;
        }
        return flag;
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
        
        std::lock_guard<std::mutex> scopedLock(mLock);
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
        std::lock_guard<std::mutex> scopedLock(mLock);
        auto begin = mConfiguration->domainsProvisionedList.begin();
        auto end   = mConfiguration->domainsProvisionedList.end();
        return std::find(begin, end, aDomainName) != end;
    }
    
    void Model::addRequestData(const Data& aRequestData)
    {
        std::lock_guard<std::mutex> scopedLock(mLock);
        mStatsHandler->addRequestData(aRequestData);
    }
    
    void Model::stopConfigurationUpdate()
    {
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout<<"Model:: stopped configuration update"<<std::endl;
#endif
        mUpdateEnabledFlag.store(false);
    }
    
    void Model::resumeConfigurationUpdate()
    {
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout<<"Model:: resumed configuration update"<<std::endl;
#endif
        mUpdateEnabledFlag.store(true);
        {
//            mConfiguration.reset(mCachedConfiguration.release());
//            applyConfiguration(*mCachedConfiguration.get(), false);
            Configuration configuration = mDataStorage->configuration();
            applyConfiguration(configuration, false);
        }
    }
    
    bool Model::shouldCollectRequestsData()
    {
        RSStatsReportingLevel statsReportingLevel = mConfiguration->statsReportingLevel;
        
        bool shouldCollect;
        {
            std::lock_guard<std::mutex> scopedLock(mLock);
            shouldCollect= statsReportingLevel == kRSStatsReportingLevelRequestsData || statsReportingLevel == kRSStatsReportingLevelFull;
        }
        return shouldCollect;
    }
}