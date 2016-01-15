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

#include <stdio.h>

#include "Model.hpp"
#include "Configuration.hpp"

#include "TestConfigurationService.h"

using namespace rs; 

void TestConfigurationService::pushTestConfig(const std::string &aProtocolName, int aOperationMode)
{
    mDefaultConfiguration.operationMode = (RSOperationModeInner) aOperationMode;
    
    mTestConfiguration = std::make_shared<Configuration>(mDefaultConfiguration);
    std::vector<std::string> allow;
    allow.push_back(aProtocolName);
    
    mTestConfiguration->allowedProtocols = allow;
    mDelegate->applyConfiguration(mTestConfiguration);
}

std::shared_ptr<const Configuration> TestConfigurationService::getActive()
{
    return mTestConfiguration;
}

void TestConfigurationService::stopUpdate() {}

void TestConfigurationService::resumeUpdate() {}

void TestConfigurationService::init()
{ 
}

void TestConfigurationService::setOperationMode(RSOperationModeInner aMode)
{
    //pass
}