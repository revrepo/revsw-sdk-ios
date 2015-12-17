//
//  Data.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Data_hpp
#define Data_hpp

#include <stdio.h>
#include <string>
#include <memory>

namespace rs
{
    class Data
    {
    public:
        Data();
        Data(const void* aBytes, size_t aLength);
        Data(const Data& aData);
        ~Data();
        Data& operator=(const Data& aData);
        std::string toString();
        void* bytes() { return mBytes; }
        const void* bytes() const { return mBytes; }
        size_t length() const { return mLength; }
    private:
        void* mBytes;
        size_t mLength;
    };
}

#endif /* Data_hpp */
