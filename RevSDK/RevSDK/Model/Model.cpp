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
        
        QUICConnection::initialize();
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
        //return std::make_shared<QUICProtocol>();
    }
    
    std::shared_ptr<Connection> Model::currentConnection()
    {
//        std::map<std::string, std::shared_ptr<Connection>> connectionDictionary = {
//        
//            {httpsProtocolName(), Connection::create<StandardConnection>() },
//            {quicProtocolName(), Connection::create<QUICConnection>() }
//        };

        std::shared_ptr<Protocol> protocol     = currentProtocol();
        std::string protocolName               = protocol.get()->protocolName();
        
        if (protocolName == httpsProtocolName())
            return Connection::create<StandardConnection>();
        else if (protocolName == quicProtocolName())
            return Connection::create<QUICConnection>();
        else
        {
            assert(false);
            return nullptr;
        }
    }
    
    void Model::loadConfiguration()
    {
        std::function<void(const Data&, const Error&)> completionBlock = [this](const Data& aData, const Error& aError){
            
#ifdef RS_ENABLE_DEBUG_LOGGING
            std::cout << "RevSDK.Model::loadConfiguration Configuration loaded\n";
#endif
            
           if (aError.isNoError())
           {
               Configuration configuration = processConfigurationData(aData);
               
               if (configuration.isValid())
               {
                   applyConfiguration(configuration, true);
                   RSStartTimer(&Model::loadConfiguration, mConfigurationRefreshTimer, mConfiguration->refreshInterval);
               }
               else
               {
#ifdef RS_ENABLE_DEBUG_LOGGING
                   std::cout << "RevSDK.Model::loadConfiguration Configuration loaded\n";
#endif
               }
           }
           else
           {
#ifdef RS_ENABLE_DEBUG_LOGGING
               std::cout << "\n" << "RevSDK.Model::loadConfiguration Failed to load configuration " << aError.description();
#endif
           }
        };
        
        mNetwork->loadConfiguration(mSDKKey, completionBlock);
    }
    
    void Model::applyConfiguration(const Configuration& aConfiguration, bool aShouldSave)
    {
        bool isUpdateEnabled = mUpdateEnabledFlag.load();
        if (isUpdateEnabled)
        {
            {
                std::lock_guard<std::mutex> lockGuard(mLock);
#ifdef RS_ENABLE_DEBUG_LOGGING
                std::cout<<"RevSDK.Model:: applying new configuretion"<<std::endl;
#endif
                
                mConfiguration = std::make_shared<Configuration>(aConfiguration);
                mStatsHandler->setReportingLevel(aConfiguration.statsReportingLevel);
                mNetwork->setStatsReportingURL(aConfiguration.statsReportingURL);
            }
            setOperationMode(aConfiguration.operationMode);
        }
        else
        {
#ifdef RS_ENABLE_DEBUG_LOGGING
            std::cout<<"RevSDK.Model:: saving new configuretion while update disabled"<<std::endl;
#endif
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
        bool hasDataToSend = true;
        do
        {
            ReportTransactionHanle statsData;
            
            {
                std::lock_guard<std::mutex> lockGuard(mLock);
#ifndef RS_DBG_MAXREQESTS
                statsData = mStatsHandler->createSendTransaction(this->mConfiguration->statsReportingMaxRequests);
#else
                statsData = mStatsHandler->createSendTransaction(RS_DBG_MAXREQESTS);
#endif
                hasDataToSend = mStatsHandler->hasRequestsData();
            }
            
            std::function<void(const Error& )> completion = [=](const Error& aError){
                std::lock_guard<std::mutex> lockGuard(mLock);
    #ifdef RS_ENABLE_DEBUG_LOGGING
                std::cout << "Stats reported" << std::endl;
    #endif
                if (aError.isNoError())
                {
                    if (statsData.cbOnSuccess)
                    {
                        statsData.cbOnSuccess();
                    }
                }
                else
                {
                    if (statsData.cbOnFail)
                    {
                        statsData.cbOnFail();
                    } 
                }
            };
            assert(statsData.Buffer.length());
            
            mNetwork->sendStats(statsData.Buffer, completion);
        }
        while (hasDataToSend);
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
        std::cout<<"RevSDK.Model::setOperationMode  peviousModeID::"<<mCurrentOperationMode<<" -> "
        <<" newModeID:"<<aOperationMode<<std::endl;
#endif
        
        mCurrentOperationMode = aOperationMode;
        
        std::cout << mConfiguration->statsReportingInterval;
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
        std::lock_guard<std::mutex> scopedLock(mLock);
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
    
    bool rs::Model::shouldTransportDomainName(std::string aDomainName)
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
    
    bool rs::Model::isDomainNameProvisioned(std::string aDomainName)
    {
        std::lock_guard<std::mutex> scopedLock(mLock);
        auto begin = mConfiguration->domainsProvisionedList.begin();
        auto end   = mConfiguration->domainsProvisionedList.end();
        return std::find(begin, end, aDomainName) != end;
    }
    
    void rs::Model::addRequestData(const Data& aRequestData)
    {
        std::lock_guard<std::mutex> lockGuard(mLock);
        mStatsHandler->addRequestData(aRequestData);
    }
    
    void Model::stopConfigurationUpdate()
    {
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout<<"RevSDK.Model:: stopped configuration update"<<std::endl;
#endif
        mUpdateEnabledFlag.store(false);
    }
    
    void rs::Model::resumeConfigurationUpdate()
    {
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout<<"RevSDK.Model:: resumed configuration update"<<std::endl;
#endif
        mUpdateEnabledFlag.store(true);
        {
//            mConfiguration.reset(mCachedConfiguration.release());
//            applyConfiguration(*mCachedConfiguration.get(), false);
            Configuration configuration = mDataStorage->configuration();
            applyConfiguration(configuration, false);
        }
    }
    
    bool rs::Model::shouldCollectRequestsData()
    {
        return  true;
        /// ASK ALEX OR ANDREW, MERGE CONFLICT
        RSStatsReportingLevel statsReportingLevel = mConfiguration->statsReportingLevel;
        
        bool shouldCollect;
        {
            std::lock_guard<std::mutex> scopedLock(mLock);
            shouldCollect= statsReportingLevel == kRSStatsReportingLevelRelease || statsReportingLevel == kRSStatsReportingLevelDebug;
        }
        return shouldCollect;
    }
}