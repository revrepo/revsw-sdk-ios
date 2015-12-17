//
//  RSNativeDataStorage.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef NativeDataStorage_h
#define NativeDataStorage_h

#include <string>
#include <iostream>
#include <vector>

namespace rs
{
    struct Configuration;
    class Data;
    
    class NativeDataStorage
    {
    public:
        
        void saveConfiguration(Configuration);
        Configuration configuration()const;
        void saveRequestData(const Data&);
        std::vector<Data> loadRequestsData();
    };
    
}
#endif