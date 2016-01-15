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

#pragma once

#include <mutex>
#include <string>
#include <vector>
#include <memory>
#include <functional>
#include <unordered_set>
#include <map>


#define RS_LOG 1

namespace rs
{
    // RANGES
    static const int kLogTagSDKMIN      = 1;
    static const int kLogTagSDKMAX      = 19;

    static const int kLogTagSTDMIN      = 30;
    static const int kLogTagSTDMAX      = 39;

    static const int kLogTagQUICMIN     = 20;
    static const int kLogTagQUICMAX     = 29;

    static const int kLogTagPerfMIN     = 30;
    static const int kLogTagPerfMAX     = 39;

    // SDK
    static const int kLogTagSDKStats             = kLogTagSDKMIN + 0;
    static const int kLogTagSDKLastMile          = kLogTagSDKStats + 1;
    static const int kLogTagSDKConfiguration     = kLogTagSDKStats + 2;
    static const int kLogTagProtocolAvailability = kLogTagSDKStats + 3;
    static const int kLogTagSDKInerception       = kLogTagSDKStats + 4;

    // STD
    static const int kLogTagSTDRequest            = kLogTagSTDMIN + 0;
    static const int kLogTagSTDStandardRedirects  = kLogTagSTDMIN + 1;
    static const int kLogTagSTDStandardConnection = kLogTagSTDMIN + 2;

    // QUIC
    static const int kLogTagQUICRequest           = kLogTagQUICMIN + 0;
    static const int kLogTagQUICLibrary           = kLogTagQUICMIN + 1;
    static const int kLogTagQUICNetwork           = kLogTagQUICMIN + 2;
    static const int kLogTagQUICTraffic           = kLogTagQUICMIN + 3;
    
    // Performance
    static const int kLogTagPerfMemory     = kLogTagPerfMIN + 0;


    class Traffic
    {
    private:
        Traffic();
    public:
        ~Traffic();
        static void initialize();
        static void logIn(int aTag, int aSize);
        static void logOut(int aTag, int aSize);
    private:
        static Traffic* instance();
        static Traffic* mInstance;
        void p_logIn(int aTag, int aSize);
        void p_logOut(int aTag, int aSize);
    public:
        std::mutex mLock;
        struct Accumulator
        {
            Accumulator() : count(0), timestamp (0) {}
            int count;
            long long timestamp;
        };
        typedef std::map<int, Accumulator> LogMap;
        LogMap mLogMap;
    };
    
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
            virtual void logTargetPrint(Level aLevel, int aTag, const char* aMessage) = 0;
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
        void logTargetPrint(Log::Level aLevel, int aTag, const char* aMessage);
    private:
        mutable std::mutex mLock;
        Entry::List mEntries;
        bool mOn;
    };
}
