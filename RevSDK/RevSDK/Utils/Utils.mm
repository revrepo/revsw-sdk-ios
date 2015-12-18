//
//  Utils.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Utils.hpp"
#include "RSUtils.h"

namespace rs
{
    //const std::string kOSKey = str
    
    std::string loadConfigurationURL()
    {
        return _loadConfigurationURL();
    }
    
    std::string reportStatsURL()
    {
        return _reportStatsURL();
    }
    
    std::string errorDescriptionKey()
    {
        return stdStringFromNSString(NSLocalizedDescriptionKey);
    }
    
    long noErrorCode()
    {
        return kRSNoErrorCode;
    }
    
    std::string httpsProtocolName()
    {
        return kRSHTTPSProtocolName;
    }
}
