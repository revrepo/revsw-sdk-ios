//
//  RSLog.cpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/8/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#include "RSLog.h"
#include <iostream>
#include <assert.h>
#include <iomanip>

#define RS_LOG 1

namespace rs
{
    class LogTargetDefault: public Log::Target
    {
    public:
        void print(Log::Level aLevel, int aTag, const char* aMessage)
        {
            std::cout << Log::levelToString(aLevel) << "|" << std::setw(3) << aTag << ": " << aMessage << std::endl;
        }
    };
}

using namespace rs;

Log* Log::mInstance = nullptr;
std::mutex Log::mInstanceLock;

void Log::initialize()
{
    if (mInstance == nullptr)
    {
        mInstanceLock.lock();

        if (mInstance == nullptr)
            mInstance = new Log();
        
        mInstanceLock.unlock();
    }
}

Log* Log::instance()
{
    assert(mInstance);
    return mInstance;
}

Log::Log()
{
    mWriteLock.lock();
    mDefaultTarget.reset(new LogTargetDefault());
    mBuffer.resize(65536);
    mWriteLock.unlock();
}

Log::~Log()
{
    
}

bool Log::enabled() const
{
#if RS_LOG
    return true;
#else
    return false;
#endif
}

void Log::addTarget(Target::Ref aTarget)
{
    Target* target = aTarget.get();
    if (target == nullptr)
        return;

    mWriteLock.lock();
    bool exists = false;
    for (auto& t : mCustomTargets)
    {
        if (t.get() == target)
        {
            exists = true;
            break;
        }
    }
    
    if (!exists)
        mCustomTargets.push_back(aTarget);
    
    mWriteLock.unlock();
}

void Log::remTarget(Target::Ref aTarget)
{
    Target* target = aTarget.get();
    if (target == nullptr)
        return;

    mWriteLock.lock();

    std::vector<Target::Ref>::iterator w = mCustomTargets.end();
    for (std::vector<Target::Ref>::iterator i = mCustomTargets.begin(), e = mCustomTargets.end(); i != e; ++i)
    {
        if (i->get() == target)
        {
            w = i;
            break;
        }
    }
    
    if (w != mCustomTargets.end())
        mCustomTargets.erase(w);

    mWriteLock.unlock();
}

void Log::p_printBufferToTargets(Level aLevel, int aTag)
{
    assert(mDefaultTarget.get());
    const char* m = &mBuffer[0];
    mDefaultTarget->print(aLevel, aTag, m);
    
    for (auto& t : mCustomTargets)
        t->print(aLevel, aTag, m);
}

int Log::printf(Level aLevel, int aTag, const char* aFormat, ...)
{
#if RS_LOG
    if (aFormat == nullptr)
        return -1;
    if (aLevel != Level::Error && aLevel != Level::Warning && aLevel != Level::Info)
        return -1;
    
    va_list args;
    va_start(args, aFormat);
    int result = p_vsprintf(aLevel, aTag, aFormat, args);
    va_end(args);
    
    return result;
#else
    return 0;
#endif
}

int Log::p_vsprintf(Level aLevel, int aTag, const char* aFormat, va_list& aArgs)
{
#if RS_LOG
    mWriteLock.lock();
    
    int cursor = 0;
    //cursor += sprintf(&mBuffer[0], "%s | %d\n", levelToString(aLevel), aTag);
    
    char* buff = &mBuffer[cursor];
    cursor += vsprintf(buff, aFormat, aArgs);
    
    p_printBufferToTargets(aLevel, aTag);
    
    assert(cursor < (int)mBuffer.size());
    
    mWriteLock.unlock();
    
    return cursor;
#else
    return 0;
#endif
}

int Log::error(int aTag, const char* aFormat, ...)
{
#if RS_LOG
    if (aFormat == nullptr)
        return -1;

    va_list args;
    va_start(args, aFormat);
    int result = instance()->p_vsprintf(Level::Error, aTag, aFormat, args);
    va_end(args);
    
    return result;
#else
    return 0;
#endif
}

int Log::warning(int aTag, const char* aFormat, ...)
{
#if RS_LOG
    if (aFormat == nullptr)
        return -1;
    
    va_list args;
    va_start(args, aFormat);
    int result = instance()->p_vsprintf(Level::Warning, aTag, aFormat, args);
    va_end(args);
    
    return result;
#else
    return 0;
#endif
}

int Log::info(int aTag, const char* aFormat, ...)
{
#if RS_LOG
    if (aFormat == nullptr)
        return -1;
    
    va_list args;
    va_start(args, aFormat);
    int result = instance()->p_vsprintf(Level::Info, aTag, aFormat, args);
    va_end(args);
    
    return result;
#else
    return 0;
#endif
}

const char* Log::levelToString(Level aLevel)
{
    switch (aLevel)
    {
        case Level::Error: return "ERR";
        case Level::Warning: return "WRN";
        case Level::Info: return "INF";
        default: { assert(false); return nullptr; }
    }
}

bool LogTarget::SimpleFilter::corresponds(const Entry& aEntry) const
{
    if (!mLevels[(int)aEntry.level()])
        return false;
    if (mTags.size() > 0)
    {
        if (mTags.find(aEntry.tag()) == mTags.end())
            return false;
    }
    
    if (mKeyword.size() > 0)
    {
        if (aEntry.message().find(mKeyword) == std::string::npos)
            return false;
    }
    
    return true;
}

LogTargetMemory::LogTargetMemory():
    mOn(true)
{
    
}

LogTargetMemory::~LogTargetMemory()
{
    
}

void LogTargetMemory::lock()
{
    mLock.lock();
}

void LogTargetMemory::unlock()
{
    mLock.unlock();
}

void LogTargetMemory::visit(VisitorFunc aVisitor) const
{
    if (!aVisitor)
        return;
    
    mLock.lock();
    aVisitor(mEntries);
    mLock.unlock();
}

void LogTargetMemory::filter(Entry::List& aList, const Filter* aFilter) const
{
    if (aFilter == nullptr)
        return;
    
    aList.clear();
    
    mLock.lock();
    for (const Entry& e : mEntries)
    {
        if (aFilter->corresponds(e))
            aList.push_back(e);
    }
    mLock.unlock();
}

void LogTargetMemory::print(Log::Level aLevel, int aTag, const char* aMessage)
{
    if (!mOn)
        return;
    if (aMessage == nullptr)
        return;
    
    mLock.lock();
    mEntries.push_back(Entry(aLevel, aTag, aMessage));
    mLock.unlock();
}