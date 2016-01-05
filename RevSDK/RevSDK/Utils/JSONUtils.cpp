//
//  JSONUtils.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <json/json.h>

#include "JSONUtils.hpp"
#include "Data.hpp"
#include "Configuration.hpp"
#include "Utils.hpp"

namespace rs
{
    Data jsonDataFromValue(Json::Value& aValue)
    {
        Json::StyledWriter writer;
        
        std::string jsonString = writer.write(aValue);
        return Data(jsonString.c_str(), jsonString.length());
    }
    
    Data jsonDataFromDataMap(std::map<std::string, Data> & aDataMap, std::map<std::string, std::string>& aStringMap)
    {
        Json::Value value;
        
        for (std::pair<std::string, Data> pair : aDataMap)
        {
            std::string key = pair.first;
            Data data       = pair.second;
            value[key]      = data.toString();
        }

        for (std::pair<std::string, std::string> pair : aStringMap)
        {
            std::string key = pair.first;
            std::string str = pair.second;
            value[key] = str;
        }
        
        return jsonDataFromValue(value);
    }
    
    Data jsonDataFromDataVector(std::vector<Data>& aDataVector)
    {
        Json::Value value(Json::ValueType::arrayValue);
        
        for (Data& data : aDataVector)
        {
            value.append(data.toString());
        }

        return jsonDataFromValue(value);
    }
    
    std::vector<std::string> vectorFromValue(Json::Value& aValue)
    {
        std::vector<std::string> vector;
        
        size_t size = aValue.size();
        
        for (int i = 0; i < size; i++)
        {
            vector.push_back(aValue[i].asString());
        }
        
        return vector;
    }
    
    Configuration processConfigurationData(const Data& aData)
    {
        Data data = aData;
        std::string dataString = data.toString();
        Json::Value value;
        Json::Reader reader;
        Configuration configuration;
        
        bool parseResult = reader.parse(dataString, value);
        
        if (!parseResult)
        {
            std::cout << "Parsing configuration failed: " << reader.getFormatedErrorMessages() << std::endl;
        }
        else
        {
            Json::Value configs                     = value[kConfigsKey][0];
            std::vector<std::string> operationModes = {kOperationModeOffString, kOperationModeTransferString, kOperationModeReportString, kOperationModeTransferReportString};
            std::vector<std::string> statsLevels    = {"debug", "release"};
            auto operation_mode_iterator            = std::find(operationModes.begin(), operationModes.end(), configs[kOperationModeKey].asString());
            auto operation_mode_index               = std::distance(operationModes.begin(), operation_mode_iterator);
            auto stats_level_iterator               = std::find(statsLevels.begin(), statsLevels.end(), configs[kStatsReportingLevelKey].asString());
            auto stats_level_index                  = std::distance(statsLevels.begin(), stats_level_iterator);
            configuration.appName                   = value[kAppNameKey].asString();
            configuration.os                        = value[kOSKey].asString();
            configuration.sdkReleaseVersion         = configs[kSDKReleaseVersionKey].asFloat();
            configuration.configurationApiURL       = configs[kConfigurationApiURLKey].asString();
            configuration.refreshInterval           = configs[kConfigurationRefreshIntervalKey].asInt();
            configuration.staleTimeout              = configs[kConfigurationStaleTimeoutKey].asInt();
            configuration.edgeHost                  = configs[kEdgeHostKey].asString();
            configuration.operationMode             = (RSOperationModeInner) operation_mode_index;
            configuration.allowedProtocols          = vectorFromValue(configs[kAllowedTransportProtocolsKey]);
            configuration.initialTransportProtocol  = configs[kInitialTransportProtocolsKey].asString();
            configuration.transportMonitoringURL    = configs[kTransportMonitoringURLKey].asString();
            configuration.statsReportingURL         = configs[kStatsReportingURLKey].asString();
            configuration.statsReportingInterval    = configs[kStatsReportingIntervalKey].asInt();
            configuration.statsReportingLevel       = (RSStatsReportingLevel)stats_level_index;
            configuration.statsReportingMaxRequests = configs[kStatsReportingMaxRequestsKey].asInt();
            configuration.domainsProvisionedList    = vectorFromValue(configs[kDomainsProvisionedListKey]);
            configuration.domainsWhiteList          = vectorFromValue(configs[kDomainsWhiteListKey]);
            configuration.domainsBlackList          = vectorFromValue(configs[kDomainsBlackListKey]);
            configuration.loggingLevel              = configs[kLoggingLevelKey].asString();
        }
        
        return configuration;
    }

}
