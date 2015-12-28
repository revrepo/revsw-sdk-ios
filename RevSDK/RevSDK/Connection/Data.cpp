//
//  Data.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/19/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "Data.hpp"

#include <iostream>

using namespace rs;

Data::Data()
{
    mLength = 0;
    mBytes  = nullptr;
}

Data::Data(const void* aBytes, size_t aLength):
    mBytes(nullptr),
    mLength(0)
{
    if (aBytes != nullptr && aLength > 0)
    {
        mLength = aLength;
        void* ptr = ::malloc(mLength);
        ::memcpy(ptr, aBytes, mLength);
        
        mBytes = std::shared_ptr<void>(ptr, []( void* mem ) {
            free(mem); // custom deleter
        });
    }
}

Data::Data(const Data& aData):
    mBytes(nullptr),
    mLength(0)
{
    if (aData.mBytes != nullptr && aData.mLength > 0)
    {
        mLength = aData.mLength;
        mBytes = aData.mBytes;
    }
}

Data::~Data()
{
    if (mBytes != nullptr)
    {
        mBytes = nullptr;
    }
}

Data& Data::operator=(const Data& aData)
{
    mLength = aData.mLength;
    mBytes = aData.mBytes;

    return *this;
}


std::string Data::toString() const
{
    if (mBytes == nullptr)
        return std::string();
    
    return std::string((char*)mBytes.get(), length());
}

