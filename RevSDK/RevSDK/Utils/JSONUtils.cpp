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
    
    Data jsonDataFromDataMap(std::map<std::string, Data> & aDataMap)
    {
        Json::Value value;
        
        for (std::pair<std::string, Data> pair : aDataMap)
        {
            std::string key = pair.first;
            Data data       = pair.second;
            value[key]      = data.toString();
        }
        
        return jsonDataFromValue(value);
    }
    
    Data jsonDataFromDataVector(std::vector<Data>& aDataVector)
    {
        Json::Value value;
        
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
            configuration.appName                   = value[kAppNameKey].asString();
            configuration.os                        = value[kOSKey].asString();
            configuration.sdkReleaseVersion         = value[kConfigsKey][kSDKReleaseVersionKey].asFloat();
            configuration.configurationApiURL       = value[kConfigurationApiURLKey].asFloat();
            configuration.refreshInterval           = value[kConfigsKey][kConfigurationRefreshIntervalKey].asInt();
            configuration.staleTimeout              = value[kConfigsKey][kConfigurationStaleTimeoutKey].asInt();
            configuration.edgeHost                  = value[kConfigsKey][kEdgeHostKey].asString();
            configuration.operationMode             = (RSOperationModeInner)value[kConfigsKey][kOperationModeKey].asInt();
            configuration.allowedProtocols          = vectorFromValue(value[kConfigsKey][kAllowedTransportProtocolsKey]);
            configuration.initialTransportProtocol  = value[kConfigsKey][kInitialTransportProtocolsKey].asString();
            configuration.transportMonitoringURL    = value[kConfigsKey][kTransportMonitoringURLKey].asString();
            configuration.statsReportingURL         = value[kConfigsKey][kStatsReportingURLKey].asString();
            configuration.statsReportingInterval    = value[kConfigsKey][kStatsReportingIntervalKey].asInt();
            configuration.statsReportingLevel       = (RSStatsReportingLevel)value[kConfigsKey][kStatsReportingLevelKey].asInt();
            configuration.statsReportingMaxRequests = value[kConfigsKey][kStatsReportingMaxRequestsKey].asInt();
            configuration.domainsProvisionedList    = vectorFromValue(value[kConfigsKey][kDomainsProvisionedListKey]);
            configuration.domainsWhiteList          = vectorFromValue(value[kConfigsKey][kDomainsWhiteListKey]);
            configuration.domainsBlackList          = vectorFromValue(value[kConfigsKey][kDomainsBlackListKey]);
        }
        
        return configuration;
    }

}
