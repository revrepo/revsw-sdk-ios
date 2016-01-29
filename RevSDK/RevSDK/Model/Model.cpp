/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

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
        
        mStatsHandler = std::unique_ptr<StatsHandler>(new StatsHandler());
        
        auto conf = new ConfigurationService(this, [this](){
            return !mProtocolSelector.haveAvailadleProtocols();
        }, [this](){
        
            mStatsHandler->stopMonitoring();
        });
        
        mConfService         = std::shared_ptr<ConfigurationService>(conf);
        mStatsReportingTimer = nullptr;
        mUsageTracker        = std::make_shared<DebugUsageTracker>();
    }
    
    Model::~Model()
    {
    }
    
    void Model::initializeContent()
    {
        QUICConnection::initialize();
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
            bool init = false;
            {
                std::lock_guard<std::mutex> scopedLock(mtx);
                if (!_instance)
                {
                    _instance = new Model;
                    init = true;
                }
            }
            
            if (init)
            {
                _instance->initializeContent();
            }
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
        std::shared_ptr<IConfigurationService> local = mConfService;
        return local->getActive()->edgeHost;
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
            if (mStatsReportingTimer == nullptr || mStatsReportingTimer->interval() != activeConf->statsReportingInterval)
            {
                Log::info(kLogTagSDKStats, "Sheduling stats reporting timer");
                Timer::scheduleTimer(mStatsReportingTimer, activeConf->statsReportingInterval, [this](){
                    this->reportStats();
                });
            }
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
                const std::string appName = this->mConfService->getActive()->appName;
                
                if (requestsCount <= 0)
                {
                    Log::error(kLogTagSDKStats, ("invalid requests count " + std::to_string(requestsCount)).c_str());
                    requestsCount = kRequestsCountMax;
                }
                
                Log::info(kLogTagSDKStats,
                          ("Paking reports, max at once :: " + std::to_string(requestsCount)).c_str());
                
                statsData = mStatsHandler->createSendTransaction(requestsCount, appName);
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
                    Model::instance()->debug_usageTracker()->statsUploadFinishedWithError();
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
        addEvent(kLogLevelInfo, 3, "SDK Initialized", 0.0f, kRSLogginLevelInfo);
        mStatsHandler->setSDKKey(mSDKKey);
    }
    
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
    
    bool rs::Model::shouldTransportDomainName(std::string aDomainName)
    {
        if (!canTransport())
        {
            return false;
        }
        
        std::lock_guard<std::mutex> scopedLock(mLock);
        
        auto conf = mConfService->getActive();

        if (domainsContainDomainName(conf->domainsBlackList, aDomainName))
        {
            return false;
        }
        
        if (domainsContainDomainName(conf->domainsProvisionedList, aDomainName))
        {
            return true;
        }
        
        if (domainsContainDomainName(conf->domainsWhiteList, aDomainName))
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
        bool shouldCollect;
        {
            std::lock_guard<std::mutex> scopedLock(mLock);
            auto conf = mConfService->getActive();
            
            RSStatsReportingLevel statsReportingLevel = conf->statsReportingLevel;
            RSOperationModeInner operationMode        = conf->operationMode;
            
            shouldCollect = statsReportingLevel == kRSStatsReportingLevelRelease || statsReportingLevel == kRSStatsReportingLevelDebug;
            shouldCollect = shouldCollect && (operationMode == kRSOperationModeInnerReport || operationMode == kRSOperationModeInnerTransportAndReport);
        }
        return shouldCollect;
    }
    
    void Model::debug_replaceConfigurationService(IConfigurationService* aNewService)
    {
        std::lock_guard<std::mutex> scopedLock(mLock);
        mConfService = std::shared_ptr<IConfigurationService>(aNewService);
        Log::info(kLogTagSDKConfiguration, "Replacing configuration service on mock");
    }
    
    
    void Model::debug_disableDebugMode()
    {
        auto conf = new ConfigurationService(this, [this](){
            return !mProtocolSelector.haveAvailadleProtocols();
        }, [this](){
            
            mStatsHandler->stopMonitoring();
        });
        
        std::lock_guard<std::mutex> scopedLock(mLock);
        mConfService = std::shared_ptr<ConfigurationService>(conf);
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
 
    void Model::addEvent(const std::string& aSeverity, const int aCode, const std::string& aMessage, const float aInterval, const RSLogginLevel aLoggingLevel)
    {
        if (mCurrentLoggingLevel >= aLoggingLevel)
        {
            Event event(aSeverity, aCode, aMessage, aInterval);
            mStatsHandler->addEvent(event);
        }
    }
}












