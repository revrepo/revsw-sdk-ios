//
//  RSLog.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/8/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#pragma once

#include <mutex>
#include <string>
#include <vector>
#include <memory>
#include <functional>
#include <unordered_set>

namespace rs
{
    const int kRSLogKey_LastMile = 10;
    const int kRSLogKey_Configuration = 11;
    
    class Log
    {
    public:
        enum class Level
        {
            Error = 0,
            Warning = 1,
            Info = 2
        };
    public:
        class Target
        {
        public:
            typedef std::shared_ptr<Target> Ref;
        public:
            Target() {}
            virtual ~Target() {}
            virtual void print(Level aLevel, int aTag, const char* aMessage) = 0;
        };
    private:
        static Log* mInstance;
        static std::mutex mInstanceLock;
    public:
        static void initialize();
        static Log* instance();
        Log();
        ~Log();
        
        bool enabled() const;
        
        void addTarget(Target::Ref aTarget);
        void remTarget(Target::Ref aTarget);

        int printf(Level aLevel, int aTag, const char* aFormat, ...);
        
        static int error(int aTag, const char* aFormat, ...);
        static int warning(int aTag, const char* aFormat, ...);
        static int info(int aTag, const char* aFormat, ...);

        static const char* levelToString(Level aLevel);
    private:
        int p_vsprintf(Level aLevel, int aTag, const char *, va_list&);
        void p_printBufferToTargets(Level aLevel, int aTag);
    private:
        std::mutex mWriteLock;
        std::vector<char> mBuffer;
        std::shared_ptr<Target> mDefaultTarget;
        std::vector<Target::Ref> mCustomTargets;
    };
    
    class LogTarget: public Log::Target
    {
    public:
        class Entry
        {
        public:
            typedef std::vector<Entry> List;
        public:
            Entry():mLevel(Log::Level::Info), mTag(0), mMessage("-") {}
            Entry(Log::Level aLevel, int aTag, const std::string& aMessage): mLevel (aLevel), mTag (aTag), mMessage (aMessage) {}
            Log::Level level() const { return mLevel; }
            int tag() const { return mTag; }
            const std::string& message() const { return mMessage; }
        private:
            Log::Level mLevel;
            int mTag;
            std::string mMessage;
        };
        
        class Filter
        {
        public:
            Filter() {}
            virtual ~Filter() {}
            
            virtual bool corresponds(const Entry& aEntry) const = 0;
        };

        class SimpleFilter : public Filter
        {
        public:
            typedef std::unordered_set<int> TagList;
        public:
            SimpleFilter() { mLevels[0] = true; mLevels[1] = true; mLevels[2] = true; }
            ~SimpleFilter() {}
            
            void setLevels(bool aErrors, bool aWarnings, bool aInfos)
            {
                mLevels[(int)Log::Level::Error] = aErrors;
                mLevels[(int)Log::Level::Warning] = aWarnings;
                mLevels[(int)Log::Level::Info] = aInfos;
            }
            void setTags(const TagList& aTags) { mTags = aTags; }
            void setKeyword(const std::string& aKeyword) { mKeyword = aKeyword; }

            const TagList& tags() const { return mTags; }
            bool errors() const { return mLevels[(int)Log::Level::Error]; }
            bool warnings() const { return mLevels[(int)Log::Level::Warning]; }
            bool infos() const { return mLevels[(int)Log::Level::Info]; }
            
            bool corresponds(const Entry& aEntry) const;
            
        private:
            std::string mKeyword;
            bool mLevels[3];
            TagList mTags;
        };
        typedef std::function<void(const Entry::List& aEntries)> VisitorFunc;
    public:
        LogTarget() {}
        ~LogTarget() {}
        virtual void visit(VisitorFunc aVisitor) const = 0;
        virtual void setOn(bool aOn) = 0;
        virtual void filter(Entry::List& aList, const Filter* aFilter) const = 0;
    };
    
    class LogTargetMemory: public LogTarget
    {
    public:
        LogTargetMemory();
        ~LogTargetMemory();
    public: // use visit if possible
        void lock();
        void unlock();
        const Entry::List& entries() const { return mEntries; }
    public:
        void visit(VisitorFunc aVisitor) const;
        void setOn(bool aOn) { mOn = aOn; }
        void filter(Entry::List& aList, const Filter* aFilter) const;
        
    protected:
        void print(Log::Level aLevel, int aTag, const char* aMessage);
    private:
        mutable std::mutex mLock;
        Entry::List mEntries;
        bool mOn;
    };
}
