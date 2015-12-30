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

