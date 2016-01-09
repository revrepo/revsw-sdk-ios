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

#include "RSLog.h"

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
#include "Event.hpp"
#include "DebugUsageTracker.hpp"

namespace rs
{
    Model::Model() 
    {
        Log::initialize();
        
        mMemoryLog.reset(new LogTargetMemory());
        Log::instance()->addTarget(mMemoryLog);
        Log::info(0, "Logging on");
        data_storage::initDataStorage();
        
        auto conf = new ConfigurationService(this, [this](){
            return !mProtocolSelector.haveAvailadleProtocols();
        });
        
        mConfService               = std::unique_ptr<ConfigurationService>(conf);
        mStatsReportingTimer       = nullptr; 
        mSpareDomainsWhiteList     = std::vector<std::string>();
        mStatsHandler              = std::unique_ptr<StatsHandler>(new StatsHandler());
        mUsageTracker              = std::make_shared<DebugUsageTracker>();
        
        //applyConfiguration(mConfService->getActive());
        
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
    
    std::shared_ptr<DebugUsageTracker> Model::debug_usageTracker() const
    {
        return mUsageTracker;
    }
    
    void Model::debug_forceReloadConfiguration()
    {
        mConfService->init();
    }
    
    std::string Model::edgeHost()
    {
        //std::lock_guard<std::mutex> scopedLock(mLock);
        return mConfService->getActive()->edgeHost;
    }
    
    std::shared_ptr<Protocol>  Model::currentProtocol()
    {
        return mProtocolSelector.bestProtocol();
        //std::make_shared<StandardProtocol>();
    }
    
    std::vector<std::string> Model::getAllowedProtocolIDs() const
    {
        return mConfService->getActive()->allowedProtocols;
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
        
        if (protocolName == standardProtocolName())
            return Connection::create<StandardConnection>();
        else if (protocolName == quicProtocolName())
            return Connection::create<QUICConnection>();
        else
        {
            assert(false);
            return nullptr;
        }
    }
    
    void Model::applyConfiguration(std::shared_ptr<const Configuration> aConfiguration)
    {
        if (aConfiguration.get() == nullptr)
        {
            return;
        }
        //scope
        {
            std::lock_guard<std::mutex> lockGuard(mLock);
            //mConfiguration = aConfiguration;
            mStatsHandler->setReportingLevel(aConfiguration->statsReportingLevel);
        }
        //setOperationMode(aConfiguration->operationMode);
        
        mProtocolSelector.onConfigurationApplied(aConfiguration);
        
        std::vector<std::string> logLevels = {kLogLevelNone, kLogLevelError, kLogLevelDebug, kLogLevelInfo};
        auto logLevelIterator = std::find(logLevels.begin(), logLevels.end(), aConfiguration->loggingLevel);
        auto logLevelIndex    = logLevelIterator == logLevels.end() ? 0 : std::distance(logLevels.begin(), logLevelIterator);
        
        mCurrentLoggingLevel = (RSLogginLevel)logLevelIndex;
        
        auto activeConf = mConfService->getActive();
        std::cout << activeConf->statsReportingInterval << std::endl;
        if (activeConf->operationMode == kRSOperationModeInnerReport ||
            activeConf->operationMode == kRSOperationModeInnerTransportAndReport)
        {
            Timer::scheduleTimer(mStatsReportingTimer, activeConf->statsReportingInterval, [this](){
                this->reportStats();
            });
        }
        else
        {
            Timer::disableTimer(mStatsReportingTimer);
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
                statsData = mStatsHandler->createSendTransaction(this->mConfService->getActive()->statsReportingMaxRequests);
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
            
            mNetwork.sendStats(mConfService->getActive()->statsReportingURL, statsData.Buffer, completion);
        }
        while (hasDataToSend);
        
        mUsageTracker->trackStatsReported();
    }
    
    void Model::initialize(std::string aSDKKey)
    {
        std::lock_guard<std::mutex> lockGuard(mLock);
        mSDKKey = aSDKKey;
        mConfService->init();
       
        if (mCurrentLoggingLevel >= kRSLogginLevelInfo)
        {
            Event initializeEvent("info", 3, "SDK Initialized", 0.0f);
            mStatsHandler->addEvent(initializeEvent);
        }
    }
    
//    void Model::setOperationMode(const RSOperationModeInner& aOperationMode)
//    {
//        std::lock_guard<std::mutex> scopedLock(mLock);
//        auto activeConf = mConfService->getActive();
//#ifdef RS_ENABLE_DEBUG_LOGGING
//        std::cout<<"RevSDK.Model::setOperationMode  peviousModeID::"
//        << activeConf->operationMode<<" -> "<<" newModeID:"<<aOperationMode<<std::endl;
//#endif
//        
//        mConfService->setOperationMode(aOperationMode);
//    }
    
    RSOperationModeInner Model::currentOperationMode()
    {
        std::lock_guard<std::mutex> scopedLock(mLock);
        return mConfService->getActive()->operationMode;
    }
    
    bool Model::canTransport()
    {
        bool flag;
        {
            std::lock_guard<std::mutex> scopedLock(mLock);
            auto conf = mConfService->getActive();
            flag =  conf->operationMode == kRSOperationModeInnerTransport ||
                    conf->operationMode == kRSOperationModeInnerTransportAndReport;
        }
        return flag;
    }
    
//    void Model::switchWhiteListOption(bool aOn)
//    {
//        std::lock_guard<std::mutex> scopedLock(mLock);
//        
//        auto conf = mConfService->getActive();
//        
//        if (aOn)
//        {
//           conf->domainsWhiteList = mSpareDomainsWhiteList;
//        }
//        else
//        {
//           mSpareDomainsWhiteList = conf->domainsWhiteList;
//           conf->domainsWhiteList.clear();
//        }
//    }
    
    bool rs::Model::shouldTransportDomainName(std::string aDomainName)
    {
        if (!canTransport())
        {
            return false;
        }
        
        std::lock_guard<std::mutex> scopedLock(mLock);
        
        auto conf = mConfService->getActive();
        
        auto begin = conf->domainsBlackList.begin();
        auto end   = conf->domainsBlackList.end();
        
        if (std::find(begin, end, aDomainName) != end)
        {
            return false;
        }
        
        begin = conf->domainsProvisionedList.begin();
        end   = conf->domainsProvisionedList.end();
        
        if (std::find(begin, end, aDomainName) != end)
        {
            return true;
        }
        
        begin = conf->domainsWhiteList.begin();
        end   = conf->domainsWhiteList.end();
        
        if (std::find(begin, end, aDomainName) != end)
        {
            return true;
        }
        
        return conf->domainsWhiteList.empty();
    }
    
    bool rs::Model::isDomainNameProvisioned(std::string aDomainName)
    {
        std::lock_guard<std::mutex> scopedLock(mLock);
        
        auto conf = mConfService->getActive();
        
        auto begin = conf->domainsProvisionedList.begin();
        auto end   = conf->domainsProvisionedList.end();
        
        return std::find(begin, end, aDomainName) != end;
    }
    
    void rs::Model::addRequestData(const Data& aRequestData)
    {
        std::lock_guard<std::mutex> lockGuard(mLock);
        mStatsHandler->addRequestData(aRequestData);
    }
    
    bool rs::Model::shouldCollectRequestsData()
    {
        auto conf = mConfService->getActive();
        
        RSStatsReportingLevel statsReportingLevel = conf->statsReportingLevel;
        RSOperationModeInner operationMode        = conf->operationMode;
        
        bool shouldCollect;
        {
            std::lock_guard<std::mutex> scopedLock(mLock);
            shouldCollect = statsReportingLevel == kRSStatsReportingLevelRelease || statsReportingLevel == kRSStatsReportingLevelDebug;
            shouldCollect = shouldCollect && (operationMode == kRSOperationModeInnerReport || operationMode == kRSOperationModeInnerTransportAndReport);
        }
        return shouldCollect;
    }
    
    void Model::debug_replaceConfigurationService(IConfigurationService* aNewService)
    {
        mConfService = std::unique_ptr<IConfigurationService>(aNewService);
        Log::info(kRSLogKey_Configuration, "Replacing configuration service on mock");
    }
    
    
    void Model::debug_disableDebugMode()
    {
        auto conf = new ConfigurationService(this, [this](){
            return !mProtocolSelector.haveAvailadleProtocols();
        });
        
        mConfService               = std::unique_ptr<ConfigurationService>(conf);
        Log::info(kRSLogKey_Configuration, "Recovering standard configuration service");
    }
    
    
    bool Model::debug_isConfigurationStale()
    {
        return mConfService->isStale();
    }
    
}












