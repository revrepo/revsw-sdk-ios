//
//  RSUtilsBridge.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "RSUtilsBridge.hpp"
#include "RSUtils.h"

namespace rs
{
   std::string errorDescriptionKey()
    {
        return stdStringFromNSString(NSLocalizedDescriptionKey);
    }
}