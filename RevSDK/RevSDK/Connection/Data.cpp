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

Data::Data(const void* aBytes, size_t aLength):
    mBytes(nullptr),
    mLength(0)
{
    if (aBytes != nullptr && aLength > 0)
    {
        mLength = aLength;
        mBytes = ::malloc(mLength);
        ::memcpy(mBytes, aBytes, mLength);
    }
}

Data::Data(const Data& aData):
    mBytes(nullptr),
    mLength(0)
{
    if (aData.mBytes != nullptr && aData.mLength > 0)
    {
        mLength = aData.mLength;
        mBytes = ::malloc(mLength);
        ::memcpy(mBytes, aData.mBytes, mLength);
    }
}

Data::~Data()
{
    if (mBytes != nullptr)
    {
        free(mBytes);
        mBytes = nullptr;
    }
}

Data& Data::operator=(const Data& aData)
{
    if (this == &aData)
        return *this;
    
    if (mBytes != nullptr)
    {
        free(mBytes);
        mBytes = nullptr;
    }
    
    if (aData.mBytes != nullptr && aData.mLength > 0)
    {
        mLength = aData.mLength;
        mBytes = ::malloc(mLength);
        ::memcpy(mBytes, aData.mBytes, mLength);
    }

    return *this;
}


std::string Data::toString()
{
//    std::string str = "";
//    char* cPtr = (char*)mBytes;
//    
//    for (int i = 0; i < mLength; i++)
//    {
//        str += *(cPtr++);
//    }
//    
//    return str;
    
    std::string result((char*)mBytes);
    result += '\0';
    return result;
}

