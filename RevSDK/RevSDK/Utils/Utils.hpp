//
//  Utils.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Utils_hpp
#define Utils_hpp

#include <stdio.h>
#include <string>

namespace rs
{

typedef enum
{
    kRSOperationModeInnerOff,
    kRSOperationModeInnerTransport,
    kRSOperationModeInnerReport,
    kRSOperationModeInnerTransportAndReport
}RSOperationModeInner;

typedef enum
{
    kRSStatsReportingLevelFull,
    kRSStatsReportingLevelDeviceData,
    kRSStatsReportingLevelRequestsData
    
}RSStatsReportingLevel;
    
    extern const std::string kOSKey;
    
    std::string loadConfigurationURL();
    std::string reportStatsURL();
    std::string errorDescriptionKey();
    long noErrorCode();
    std::string httpsProtocolName();
}

#endif /* Utils_hpp */
