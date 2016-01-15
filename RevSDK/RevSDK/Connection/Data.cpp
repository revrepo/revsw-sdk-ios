/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

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

Data Data::clone() const
{
    if (isEmpty())
        return Data();
    
    return Data(bytes(), length());
}

