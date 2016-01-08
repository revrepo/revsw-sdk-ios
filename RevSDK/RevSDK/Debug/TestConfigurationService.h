//
//  TestServiceManager.h
//  RevTest App
//
//  Created by Vlad Joss on 08.01.16.
//
//
#pragma once

#include <stack> 

#include "IConfigurationService.h"

namespace rs
{
    class Configuration;
    class TestConfigurationService : public IConfigurationService
    {
    private:
        std::stack<Configuration> mTestConfigurations;
        
    public:
        void pushTestConfig(const std::string& aProtocolName, int aOperationMode);
        
        void setOperationMode(RSOperationModeInner aMode) override;
        
        void init() override;
        
        void stopUpdate() override;
        void resumeUpdate() override;
        
        void next();
        
        bool hasTests() { return !mTestConfigurations.empty(); }
        
        std::shared_ptr<const Configuration> getActive() const override;
    };
}












