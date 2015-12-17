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
            configuration.appName                   = value["app_name"].asString();
            configuration.os                        = value["os"].asString();
            configuration.sdkReleaseVersion         = value["configs"]["sdk_release_version"].asFloat();
            configuration.configurationApiURL       = value["configuration_api_url"].asFloat();
            configuration.refreshInterval           = value["configs"]["configuration_refresh_interval_sec"].asInt();
            configuration.staleTimeout              = value["configs"]["configuration_stale_timeout_sec"].asInt();
            configuration.edgeHost                  = value["configs"]["edge_host"].asString();
            configuration.operationMode             = (RSOperationModeInner)value["configs"]["operation_mode"].asInt();
            configuration.allowedProtocols          = vectorFromValue(value["configs"]["allowed_transport_protocols"]);
            configuration.initialTransportProtocol  = value["configs"]["initial_transport_protocol"].asString();
            configuration.transportMonitoringURL    = value["configs"]["transport_monitoring_url"].asString();
            configuration.statsReportingURL         = value["configs"]["stats_reporting_url"].asString();
            configuration.statsReportingInterval    = value["configs"]["stats_reporting_interval"].asInt();
            configuration.statsReportingLevel       = (RSStatsReportingLevel)value["configs"]["stats_reporting_levelt"].asInt();
            configuration.statsReportingMaxRequests = value["configs"]["stats_reporting_max_requests_per_report"].asInt();
            configuration.domainsProvisionedList    = vectorFromValue(value["configs"]["domains_provisioned_list"]);
            configuration.domainsWhiteList          = vectorFromValue(value["configs"]["domains_white_list"]);
            configuration.domainsBlackList          = vectorFromValue(value["configs"]["domains_black_list"]);
        }
        
        return configuration;
    }

}
