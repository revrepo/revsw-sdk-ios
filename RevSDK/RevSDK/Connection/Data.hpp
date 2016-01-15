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

#ifndef Data_hpp
#define Data_hpp

#include <stdio.h>
#include <string>
#include <memory>
#include <vector>

#include "LeakDetector.h"

namespace rs
{
    class Data
    {
        REV_LEAK_DETECTOR(Data);
        
    public:
        class Content
        {
        public:
            typedef std::shared_ptr<Content> Ref;
        public:
            Content(const Content&) = delete;
            Content& operator=(const Content&) = delete;
            
            Content(size_t aLength);
            ~Content();
            
            size_t length() const { return mLength; }
            const void* bytes() const { return mBytes; }
            void* bytes() { return mBytes; }
            
        private:
            size_t mLength;
            void* mBytes;
        };
        typedef std::vector<Data> List;
    public:
        Data();
        Data(const void* aBytes, size_t aLength);
        ~Data();
        
        std::string toString() const;
        
        void* bytes()
        {
            return (mContent.get() != nullptr) ? (mContent->bytes()) : (nullptr);
        }
        const void* bytes() const
        {
            return (mContent.get() != nullptr) ? (mContent->bytes()) : (nullptr);
        }
        size_t length() const
        {
            return (mContent.get() != nullptr) ? (mContent->length()) : (0);
        }
        
        static Data concat(Data d0, Data d1);
        Data byAppendingData(const void* aData, size_t aDataLen);
        Data clone() const;
        
        bool isEmpty() const { return mContent.get() == nullptr; }
        
    private:
        Content::Ref mContent;
    };
}

#endif /* Data_hpp */
