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
    class ProxyTarget: public Log::Target
    {
    public:
        ProxyTarget(Log::Target* aDst):mDst(aDst) {}
        ~ProxyTarget() {}
        void logTargetPrint(Log::Level aLevel, int aTag, const char* aMessage)
        {
            if (mDst)
                mDst->logTargetPrint(aLevel, aTag, aMessage);
        }
    private:
        Log::Target* mDst;
    };
    
    Model::Model():
        mEventTriggerOn (false)
    {
        Log::initialize();
        Traffic::initialize();
        mMemoryLog.reset(new LogTargetMemory());
        mProxy.reset(new ProxyTarget(this));
        Log::instance()->addTarget(mMemoryLog);
        Log::instance()->addTarget(mProxy);
        Log::info(0, "Logging on");
        data_storage::initDataStorage();
        
        mStatsHandler              = std::unique_ptr<StatsHandler>(new StatsHandler());
        
        auto conf = new ConfigurationService(this, [this](){
            return !mProtocolSelector.haveAvailadleProtocols();
        }, [this](){
        
            mStatsHandler->stopMonitoring();
        });
        
        mConfService               = std::unique_ptr<ConfigurationService>(conf);
        mStatsReportingTimer       = nullptr; 
        mSpareDomainsWhiteList     = std::vector<std::string>();
        mUsageTracker              = std::make_shared<DebugUsageTracker>();
        
        //applyConfiguration(mConfService->getActive());
        
        QUICConnection::initialize();
    }
    
    Model::~Model()
    {
    }
    
    void Model::switchEventTrigger(bool aOn, std::function<void(rs::Log::Level, const char*, const char*)> aCallback)
    {
        mEventTriggerOn = aOn;
        mEventTriggerCallback = aCallback;
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
        std::shared_ptr<Protocol> protocol     = currentProtocol();
        std::string protocolName               = protocol.get()->protocolName();
        return connectionForProtocolName(protocolName);
    }
    
    std::shared_ptr<Connection> Model::connectionForProtocolName(const std::string& aProtocolName)
    {
        if (aProtocolName == standardProtocolName())
            return Connection::create<StandardConnection>();
        else if (aProtocolName == quicProtocolName())
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
            Log::error(kLogTagSDKConfiguration, "Applying null(empty) configuration");
            return;
        }
        //scope
        {
            std::lock_guard<std::mutex> lockGuard(mLock);
            //mConfiguration = aConfiguration;
            mStatsHandler->setReportingLevel(aConfiguration->statsReportingLevel);
            
            if (aConfiguration->operationMode == kRSOperationModeInnerReport || aConfiguration->operationMode == kRSOperationModeInnerTransportAndReport)
            {
                mStatsHandler->startMonitoring();
            }
            else
            {
                mStatsHandler->stopMonitoring();
            }
        }
        
        //setOperationMode(aConfiguration->operationMode);
        
        mProtocolSelector.onConfigurationApplied(aConfiguration);
        
        std::vector<std::string> logLevels = {kLogLevelNone, kLogLevelError, kLogLevelDebug, kLogLevelInfo};
        auto logLevelIterator = std::find(logLevels.begin(), logLevels.end(), aConfiguration->loggingLevel);
        auto logLevelIndex    = logLevelIterator == logLevels.end() ? 0 : std::distance(logLevels.begin(), logLevelIterator);
        
        mCurrentLoggingLevel = (RSLogginLevel)logLevelIndex;
    }
    
    void Model::scheduleStatsReporting()
    {
        auto activeConf = mConfService->getActive();
    
        if (activeConf->operationMode == kRSOperationModeInnerReport ||
            activeConf->operationMode == kRSOperationModeInnerTransportAndReport)
        {
            Log::info(kLogTagSDKStats, "Sheduling stats reporting timer");
            Timer::scheduleTimer(mStatsReportingTimer, activeConf->statsReportingInterval, [this](){
                this->reportStats();
            });
        }
        else
        {
            Log::warning(kLogTagSDKStats, "DISABLING stats reporting timer");
            Timer::disableTimer(mStatsReportingTimer);
        }
    }
    
    void Model::reportStats()
    {
        Log::info(kLogTagSDKStats, "Reporting stats...");
        bool hasDataToSend = true;
        do
        {
            ReportTransactionHanle statsData;
            
            {
                std::lock_guard<std::mutex> lockGuard(mLock);
#ifndef RS_DBG_MAXREQESTS
                int requestsCount = this->mConfService->getActive()->statsReportingMaxRequests;
                
                assert(requestsCount);
                Log::info(kLogTagSDKStats,
                          ("Paking reports, max at once :: " + std::to_string(requestsCount)).c_str());
                
                statsData = mStatsHandler->createSendTransaction(requestsCount);
#else
                statsData = mStatsHandler->createSendTransaction(RS_DBG_MAXREQESTS);
#endif
                hasDataToSend = mStatsHandler->hasRequestsData();
            }
            
            std::function<void(const Error& )> completion = [=](const Error& aError){
                std::lock_guard<std::mutex> lockGuard(mLock);
                if (aError.isNoError())
                {
                    Log::info(kLogTagSDKStats, "Stats reported with success");
                    if (statsData.cbOnSuccess)
                    {
                        statsData.cbOnSuccess();
                    }
                }
                else
                {
                    Log::error(kLogTagSDKStats, "Stats reported with an error");
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
        Log::info(kLogTagSDKConfiguration, "Replacing configuration service on mock");
    }
    
    
    void Model::debug_disableDebugMode()
    {
        auto conf = new ConfigurationService(this, [this](){
            return !mProtocolSelector.haveAvailadleProtocols();
        }, [this](){
            
            mStatsHandler->stopMonitoring();
        });
        
        mConfService = std::unique_ptr<ConfigurationService>(conf);
        mConfService->init();
        Log::info(kLogTagSDKConfiguration, "Recovering standard configuration service");
    }
    
    std::shared_ptr<const Configuration> Model::getActiveConfiguration()const
    {
        return mConfService->getActive();
    }
    
    void Model::logTargetPrint(Log::Level aLevel, int aTag, const char* aMessage)
    {
        if (!mEventTriggerOn || !mEventTriggerCallback)
            return;
        
        if (aTag >= kLogTagQUICMIN && aTag <= kLogTagQUICMAX && (aLevel == Log::Level::Warning || aLevel == Log::Level::Error))
        {
            std::string title = "QUIC";
            
            switch (aTag)
            {
                case kLogTagQUICRequest: title += " request"; break;
                case kLogTagQUICLibrary: title += " library"; break;
                case kLogTagQUICNetwork: title += " network"; break;
                default: title += " unknown"; break;
            }
            
            switch (aLevel)
            {
                case Log::Level::Info:    title += " info";    break;
                case Log::Level::Warning: title += " warning"; break;
                case Log::Level::Error:   title += " error";   break;
                default: title += " something";  break;
            }
            
            mEventTriggerCallback(aLevel, title.c_str(), aMessage);
        }
    }
    
    
    bool Model::debug_isConfigurationStale()
    {
        return mConfService->isStale();
    }
    
}












