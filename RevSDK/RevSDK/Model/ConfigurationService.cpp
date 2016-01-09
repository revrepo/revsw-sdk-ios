
#include <assert.h>

#include <chrono>
#include <ctime>

#include "Error.hpp"
#include "ConfigurationService.h"
#include "Network.hpp"
#include "Model.hpp"
#include "DebugUsageTracker.hpp"

using namespace rs;

const std::string kTimestampKey = "kRS_timestamp";

//todo : remove

ConfigurationService::ConfigurationService(IConfvigServDelegate* aDelegate, std::function<bool()> fExternalStaleCond, std::function<void()> aStaleCallback) :
    mUpdateEnabledFlag(true),
    mDelegate(aDelegate),
    mStaleOnFlag(false),
    mStaleCallback(aStaleCallback)
{
    auto secCnt = data_storage::getIntForKey(kTimestampKey);
    
    std::chrono::system_clock::duration d(secCnt);
    
    mLastUpdated = std::chrono::system_clock::time_point(d);
    
    mNetwork = std::unique_ptr<Network>(new Network());
    
    // :(
    cbAdditionalStaleCondition = fExternalStaleCond;
    
    Configuration configuration = data_storage::configuration();
    mActiveConfiguration = std::make_shared<Configuration>(configuration);
    
    mStaleConfiguration =std::make_shared<Configuration>();
    mStaleConfiguration->operationMode = RSOperationModeInner::kRSOperationModeInnerOff;
    
    Timer::scheduleTimer(mConfigurationRefreshTimer, configuration.refreshInterval, [this]{
        this->loadConfiguration();
    });
}

ConfigurationService::~ConfigurationService()
{ 
}

void ConfigurationService::init()
{
    loadConfiguration();
}

void ConfigurationService::stopUpdate()
{
    std::shared_ptr<Configuration> config = mActiveConfiguration;
    data_storage::saveConfiguration(*config);
    mUpdateEnabledFlag.store(false);
}

void ConfigurationService::resumeUpdate()
{
    mUpdateEnabledFlag.store(true);
    {
        Configuration configuration = data_storage::configuration();
        mActiveConfiguration = std::make_shared<Configuration>(configuration);
        mDelegate->applyConfiguration(getActive());
        mDelegate->scheduleStatsReporting();
    }
}

std::shared_ptr<const Configuration> ConfigurationService::getActive()
{
    if (isStale())
    {
        if (!mStaleOnFlag)
        {
            mStaleOnFlag = true;
            
            if (mStaleCallback)
            {
                mStaleCallback();
            }
        }
        
        return mStaleConfiguration;
    }
    
    return mActiveConfiguration;//
}

void ConfigurationService::loadConfiguration()
{
    std::function<void(const Data&, const Error&)> completionBlock = [this](const Data& aData, const Error& aError){
        
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout << "RevSDK.Model::loadConfiguration Configuration loaded\n";
#endif
        if (aError.isNoError())
        {
            Error error;
            
            bool isValid = isValidConfiguration(aData, &error);
            
            if (isValid)
            {
                mStaleOnFlag = false;
                
                Configuration configuration = processConfigurationData(aData);
                
                Model::instance()->debug_usageTracker()->trackConfigurationPulled(aData);
                
                int refreshInterval = 0;
                mLastUpdated = std::chrono::system_clock::now();
                data_storage::saveIntForKey(kTimestampKey, mLastUpdated.load().time_since_epoch().count());
                
                if (mUpdateEnabledFlag)
                {
                    mActiveConfiguration = std::make_shared<Configuration>(configuration);
                    mDelegate->applyConfiguration(mActiveConfiguration);
                    mDelegate->scheduleStatsReporting();
                    
                    refreshInterval = mActiveConfiguration->refreshInterval;
                }
                else
                {
                    data_storage::saveConfiguration(configuration);
                    
                    refreshInterval = configuration.refreshInterval;
                }
                
                //////////////////// SCOPE ///////////////////////
                {
                    //std::lock_guard<std::mutex> lock(mTimeLock);
                    
                    Timer::scheduleTimer(mConfigurationRefreshTimer,
                                         mActiveConfiguration->refreshInterval,[this] {
                                             this->loadConfiguration();
                                         });
                }
            }
            else
            {
                std::cout << "RevSDK.Model::loadConfiguration Failed to validate configuration " << error.description() << std::endl;
            }
        }
        else
        {
#ifdef RS_ENABLE_DEBUG_LOGGING
            std::cout << "\n" << "RevSDK.Model::loadConfiguration Failed to load configuration "
            << aError.description() << std::endl;;
#endif
        }
    };
    
    mNetwork->loadConfiguration(Model::instance()->SDKKey(), completionBlock);
}

bool ConfigurationService::isStale() const
{
    typedef std::chrono::seconds tSec;
    typedef std::chrono::system_clock tSclock;
    auto last = mLastUpdated.load();
    
    auto span = std::chrono::duration_cast<tSec>(tSclock::now() - last);
    
    int staleTimeout = mActiveConfiguration->staleTimeout;
    int64_t timeSincleLastUPD = span.count();
    
    bool externalFlag = cbAdditionalStaleCondition();
    
    return (staleTimeout < timeSincleLastUPD) || externalFlag;
}

void ConfigurationService::setOperationMode(RSOperationModeInner aMode)
{
    if (!isStale())
    {
        mActiveConfiguration->operationMode = aMode;
    }
    else
    {
#ifdef RS_ENABLE_DEBUG_LOGGING
        std::cout << "\n" << "RevSDK.ConfigurationService::setOperationMode\n"
        "    Stale Configuration is immutable, doing nothign" <<std::endl;
#endif
    }
}





















