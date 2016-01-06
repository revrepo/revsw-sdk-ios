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
#include <vector>

namespace rs
{
    class Data
    {
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
        
        bool isEmpty() const { return mContent.get() == nullptr; }
        
    private:
        Content::Ref mContent;
    };
}

#endif /* Data_hpp */
