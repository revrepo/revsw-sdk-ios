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
    mDefaultConfiguration.allowedProtocols.push_back(aProtocolName);
    mDefaultConfiguration.operationMode = (RSOperationModeInner) aOperationMode;
    
    mTestConfiguration = std::make_shared<Configuration>(mDefaultConfiguration);
    mDelegate->applyConfiguration(mTestConfiguration);
}

std::shared_ptr<const Configuration> TestConfigurationService::getActive() const
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