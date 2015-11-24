//
//  ConfigurationProcessor.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef ConfigurationProcessor_hpp
#define ConfigurationProcessor_hpp

#include <stdio.h>
#include <string>

namespace rs
{
    class Data;
    struct Configuration;
    
    class ConfigurationProcessor
    {
       public:
        static Configuration processConfigurationData(Data&);
    };
}

#endif /* ConfigurationProcessor_hpp */
