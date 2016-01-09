
#include <assert.h>

#include <chrono>
#include <ctime>

#include "RSLog.h"

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
    
    if (!isTimedOut())
    {
        Log::info(kRSLogKey_Configuration, "Restored config.");
        aDelegate->applyConfiguration(mActiveConfiguration);
    }
    
    mStaleConfiguration =std::make_shared<Configuration>();
    mStaleConfiguration->operationMode = RSOperationModeInner::kRSOperationModeInnerOff;
    
    Timer::scheduleTimer(mConfigurationRefreshTimer, configuration.refreshInterval, [this]{
        Log::info(kRSLogKey_Configuration, "Trying to load configuration...");
        this->loadConfiguration();
    });
    
    
    Log::info(kRSLogKey_Configuration, "ConfigurationService was just created.");
}

bool ConfigurationService::isTimedOut() const
{
    typedef std::chrono::seconds tSec;
    typedef std::chrono::system_clock tSclock;
    auto last = mLastUpdated.load();
    
    auto span = std::chrono::duration_cast<tSec>(tSclock::now() - last);
    
    int staleTimeout = mActiveConfiguration->staleTimeout;
    int64_t timeSincleLastUPD = span.count();
    
    
    return (staleTimeout < timeSincleLastUPD);
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
            Log::info(kRSLogKey_Configuration, "Configuration is stale or no protocols available, OFF MODE");
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
        
        if (aError.isNoError())
        {
            Error error;
            
            bool isValid = isValidConfiguration(aData, &error);
            
            if (isValid)
            {
                mStaleOnFlag = false;
                Log::info(kRSLogKey_Configuration, "ConfigurationService: new conf received, valid");
                
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
                    data_storage::saveConfiguration(configuration);
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
                Log::error(kRSLogKey_Configuration, "Failed to load configuration.");
            }
        }
        else
        {
            Log::error(kRSLogKey_Configuration, "Failed to load configuration.");
        }
    };
    
    mNetwork->loadConfiguration(Model::instance()->SDKKey(), completionBlock);
}

bool ConfigurationService::isStale() const
{ 
    bool externalFlag = cbAdditionalStaleCondition();
    
    return isTimedOut() || externalFlag;
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
        Log::warning(kRSLogKey_Configuration, "Can't change operation mode - stale conf is immutable.");
#endif
    }
}





















