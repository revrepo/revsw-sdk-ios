//
//  JSONUtils.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef JSONUtils_hpp
#define JSONUtils_hpp

#include <stdio.h>
#include <vector>

namespace rs
{
    class Data;
    class Configuration;
    
    Data jsonDataFromDataVector(std::vector<Data> &);
    Configuration processConfigurationData(const Data& aData);
}

#endif /* JSONUtils_hpp */
