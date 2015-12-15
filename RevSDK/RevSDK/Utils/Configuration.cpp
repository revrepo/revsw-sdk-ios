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
    }
    
    Data Configuration::toData()
    {
//        Data data;
//        data.bytes  = this;
//        data.length = sizeof(*this);
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
}