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

Data::Content::Content(size_t aLength):
    mLength(aLength),
    mBytes(nullptr)
{
    if (mLength != 0)
        mBytes = malloc(mLength);
}

Data::Content::~Content()
{
    if (mBytes != nullptr)
        free(mBytes);
}

Data::Data():
    mContent(nullptr)
{
}

Data::Data(const void* aBytes, size_t aLength):
    mContent(nullptr)
{
    if (aLength > 0)
    {
        mContent.reset(new Content(aLength));
        if (aBytes != nullptr)
            ::memcpy(mContent->bytes(), aBytes, aLength);
    }
}

Data::~Data()
{
}

std::string Data::toString() const
{
    if (mContent.get() == nullptr)
        return std::string();
    
    return std::string((char*)bytes(), length());
}

Data Data::concat(Data d0, Data d1)
{
    Data data(nullptr, d0.length() + d1.length());
    char* p = (char*)data.bytes();
    ::memcpy(&p[0], d0.bytes(), d0.length());
    ::memcpy(&p[d0.length()], d1.bytes(), d1.length());
    return data;
}

Data Data::byAppendingData(const void* aData, size_t aDataLen)
{
    if (isEmpty())
    {
        return Data(aData, aDataLen);
    }
    Data data(nullptr, length() + aDataLen);
    char* p = (char*)data.bytes();
    ::memcpy(&p[0], bytes(), length());
    ::memcpy(&p[length()], aData, aDataLen);
    return data;
}

