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

namespace rs
{
    Model::Model() 
    {
        data_storage::initDataStorage();
        
        auto conf = new ConfigurationService(this);
        
        mConfService               = std::unique_ptr<ConfigurationService>(conf);
        mStatsReportingTimer       = nullptr; 
        mSpareDomainsWhiteList     = std::vector<std::string>();
        mStatsHandler              = std::unique_ptr<StatsHandler>(new StatsHandler());
        
        applyConfiguration(mConfService->getActive());
        
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
        //std::lock_guard<std::mutex> scopedLock(mLock);
        return mConfService->getActive()->edgeHost;
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
    
    void Model::applyConfiguration(std::shared_ptr<const Configuration> aConfiguration)
    {
        {
            std::lock_guard<std::mutex> lockGuard(mLock);
            //mConfiguration = aConfiguration;
            mStatsHandler->setReportingLevel(aConfiguration->statsReportingLevel);
        }
        setOperationMode(aConfiguration->operationMode);
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
    }
    
    void Model::initialize(std::string aSDKKey)
    {
        std::lock_guard<std::mutex> lockGuard(mLock);
        mSDKKey = aSDKKey;
        mConfService->init();
    }
    
    void Model::setOperationMode(const RSOperationModeInner& aOperationMode)
    {
        std::lock_guard<std::mutex> scopedLock(mLock);
        auto activeConf = mConfService->getActive();
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout<<"RevSDK.Model::setOperationMode  peviousModeID::"
        << activeConf->operationMode<<" -> "<<" newModeID:"<<aOperationMode<<std::endl;
#endif
        
        mConfService->setOperationMode(aOperationMode);
        
        std::cout << activeConf->statsReportingInterval;
        if (activeConf->operationMode == kRSOperationModeInnerReport ||
            activeConf->operationMode == kRSOperationModeInnerTransportAndReport)
        {
            //RSStartTimer(&Model::reportStats, mStatsReportingTimer, activeConf->statsReportingInterval);
            Timer::scheduleTimer(mStatsReportingTimer, activeConf->statsReportingInterval, [this](){
                this->reportStats();
            });
        }
        else
        {
            Timer::disableTimer(mStatsReportingTimer);
        }
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
    
    void Model::stopConfigurationUpdate()
    {
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout<<"RevSDK.Model:: stopped configuration update"<<std::endl;
#endif
        mConfService->stopUpdate();
    }
    
    void rs::Model::resumeConfigurationUpdate()
    {
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout<<"RevSDK.Model:: resumed configuration update"<<std::endl;
#endif
        mConfService->resumeUpdate();
    }
    
    bool rs::Model::shouldCollectRequestsData()
    {
        return  true;
        /// ASK ALEX OR ANDREW, MERGE CONFLICT
        auto conf = mConfService->getActive();
        
        RSStatsReportingLevel statsReportingLevel = conf->statsReportingLevel;
        
        bool shouldCollect;
        {
            std::lock_guard<std::mutex> scopedLock(mLock);
            shouldCollect= statsReportingLevel == kRSStatsReportingLevelRelease || statsReportingLevel == kRSStatsReportingLevelDebug;
        }
        return shouldCollect;
    }
}