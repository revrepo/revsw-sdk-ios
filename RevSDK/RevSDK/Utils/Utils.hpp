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
    kRSStatsReportingLevelNormal,
    kRSStatsReportingLevelLimited
}RSStatsReportingLevel;
    
}

#endif /* Utils_hpp */
