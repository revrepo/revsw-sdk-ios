//
//  IConfigurationService.hpp
//  RevSDK
//
//  Created by Vlad Joss on 08.01.16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#pragma once

namespace rs
{
    class Configuration;
    
    class IConfigurationService
    {
    public:
        virtual ~IConfigurationService() = default;
        
        virtual void setOperationMode(RSOperationModeInner aMode) = 0;
        
        virtual void init() = 0;
        
        virtual void stopUpdate() = 0;
        virtual void resumeUpdate() = 0;
        
        virtual std::shared_ptr<const Configuration> getActive() const = 0;
    };
}
