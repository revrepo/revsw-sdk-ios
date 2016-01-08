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

void TestConfigurationService::next()
{
    if (mTestConfigurations.size() > 0)
    {
        mTestConfigurations.pop();
    }
}

void TestConfigurationService::pushTestConfig(const std::string &aProtocolName, int aOperationMode)
{
    Configuration test;
    
    test.allowedProtocols.push_back(aProtocolName);
    test.operationMode = (RSOperationModeInner) aOperationMode;
    
    mTestConfigurations.push(test);
}

std::shared_ptr<const Configuration> TestConfigurationService::getActive() const
{
    return std::make_shared<const Configuration>(mTestConfigurations.top());
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