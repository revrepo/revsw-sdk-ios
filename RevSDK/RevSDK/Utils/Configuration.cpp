//
//  Configuration.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <iostream>

#include "Configuration.hpp"
#include "Data.hpp"
#include "Utils.hpp"

namespace rs
{
    Configuration::Configuration(const Configuration& aConfiguration)
    {
        appName                   = aConfiguration.appName;
        os                        = aConfiguration.os;
        operationMode             = aConfiguration.operationMode;
        sdkReleaseVersion         = aConfiguration.sdkReleaseVersion;
        configurationApiURL       = aConfiguration.configurationApiURL;
        refreshInterval           = aConfiguration.refreshInterval;
        staleTimeout              = aConfiguration.staleTimeout;
        edgeHost                  = aConfiguration.edgeHost;
        allowedProtocols          = aConfiguration.allowedProtocols;
        initialTransportProtocol  = aConfiguration.initialTransportProtocol;
        transportMonitoringURL    = aConfiguration.transportMonitoringURL;
        statsReportingURL         = aConfiguration.statsReportingURL;
        statsReportingInterval    = aConfiguration.statsReportingInterval;
        statsReportingLevel       = aConfiguration.statsReportingLevel;
        statsReportingMaxRequests = aConfiguration.statsReportingMaxRequests;
        domainsProvisionedList    = aConfiguration.domainsProvisionedList;
        domainsWhiteList          = aConfiguration.domainsWhiteList;
        domainsBlackList          = aConfiguration.domainsBlackList;
        loggingLevel              = aConfiguration.loggingLevel;
    }
    
    Data Configuration::toData()
    {
        return Data(this, sizeof(*this));
    }
    
    Configuration Configuration::configurationFromData(Data aData)
    {
        Configuration* configuration = (Configuration *)aData.bytes();
        return Configuration(*configuration);
    }
    
    void Configuration::print()const
    {
        std::cout << "protocols    " << allowedProtocols.size() << std::endl;
    }
    
    bool Configuration::isValid()
    {
        if (sdkReleaseVersion != kSDKVersionNumber)
        {
            return false;
        }
        
        if (!edgeHost.length())
        {
            return false;
        }
        
        if (!configurationApiURL.length())
        {
            return false;
        }
        
        if (!isValidURL(statsReportingURL))
        {
            return false;
        }
        
        if (!isValidURL(transportMonitoringURL))
        {
            return false;
        }
        
        return true;
    }
}