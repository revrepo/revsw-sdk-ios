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
        std::shared_ptr<Configuration> mTestConfiguration;
        
        IConfvigServDelegate* mDelegate;
        
    public:
        TestConfigurationService(IConfvigServDelegate* aDelegate) : mDelegate(aDelegate){};
        
        void pushTestConfig(const std::string& aProtocolName, int aOperationMode);
        
        void setOperationMode(RSOperationModeInner aMode) override;
        
        void init() override;
        
        void stopUpdate() override;
        void resumeUpdate() override;
        
        std::shared_ptr<const Configuration> getActive() override;
    };
}












