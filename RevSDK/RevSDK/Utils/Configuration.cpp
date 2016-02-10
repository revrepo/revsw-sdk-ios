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
        //10.02.16 Perepelitsa: copying copying values of a/b testing
        abTesMode                 = aConfiguration.abTesMode;
        abTestingRatio            = aConfiguration.abTestingRatio;
        //
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
}