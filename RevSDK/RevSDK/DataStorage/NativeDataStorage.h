//
//  RSNativeDataStorage.h
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <string.h>
#include <iostream>

namespace rs
{
    struct Configuration;
    
    class NativeDataStorage
    {
    public:
        
        void saveConfiguration(Configuration);
        Configuration configuration()const;
    };
    
}