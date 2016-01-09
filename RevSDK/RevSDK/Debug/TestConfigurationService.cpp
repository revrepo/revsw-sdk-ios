//
//  TestConfigurationService.cpp
//  RevTest App
//
//  Created by Vlad Joss on 08.01.16.
//
//

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