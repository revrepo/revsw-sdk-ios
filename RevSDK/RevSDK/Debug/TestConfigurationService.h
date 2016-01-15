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

#pragma once

#include <stack> 

#include "IConfigurationService.h"
#include "Configuration.hpp"

namespace rs
{
    class Configuration;
    class TestConfigurationService : public IConfigurationService
    {
    private:
        std::shared_ptr<Configuration> mTestConfiguration;
        Configuration mDefaultConfiguration;
        IConfvigServDelegate* mDelegate;
        
    public:
        TestConfigurationService(IConfvigServDelegate* aDelegate, const Configuration& aConfiguration) : mDelegate(aDelegate), mDefaultConfiguration(aConfiguration){};
        
        void pushTestConfig(const std::string& aProtocolName, int aOperationMode);
        
        void setOperationMode(RSOperationModeInner aMode) override;
        
        void init() override;
        
        void stopUpdate() override;
        void resumeUpdate() override;
        
        std::shared_ptr<const Configuration> getActive() override;
    };
}












