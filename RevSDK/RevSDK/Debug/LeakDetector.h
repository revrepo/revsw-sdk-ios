/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
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

#ifndef LeakDetector_h
#define LeakDetector_h

#include <assert.h>
#include <iostream>

template <class OwnerClass>
class LeakedObjectDetector
{
public:
    
    LeakedObjectDetector() noexcept                                 { ++(getCounter().numObjects); }
    LeakedObjectDetector (const LeakedObjectDetector&) noexcept     { ++(getCounter().numObjects); }
    
    ~LeakedObjectDetector()
    {
        if (--(getCounter().numObjects) < 0)
        {
            std::cout << "Dangling pointer deletion! Class: " << getLeakedObjectClassName() << std::endl;
            //assert(false);
        }
    }
    
private:
    
    class LeakCounter
    {
    public:
        LeakCounter() noexcept {}
        
        ~LeakCounter()
        {
            if (numObjects.load() > 0)
            {
                std::cout << "Leaked objects detected: " << numObjects.load() << " instance(s) of class " << getLeakedObjectClassName() << std::endl;
                //assert(false);
            }
        }
        
        std::atomic<int> numObjects;
    };
    
    static const char* getLeakedObjectClassName()
    {
        return OwnerClass::getLeakedObjectClassName();
    }
    
    static LeakCounter& getCounter() noexcept
    {
        static LeakCounter counter;
        return counter;
    }
};

#if (DEBUG)
#define CONCAT_MACRO_HELPER(a, b) a ## b
#define CONCAT_MACRO(item1, item2)  CONCAT_MACRO_HELPER (item1, item2)
#define REV_LEAK_DETECTOR(OwnerClass) \
    friend class LeakedObjectDetector<OwnerClass>; \
    static const char* getLeakedObjectClassName() noexcept { return #OwnerClass; } \
    LeakedObjectDetector<OwnerClass> CONCAT_MACRO (leakDetector, __LINE__);
#else
#define REV_LEAK_DETECTOR(OwnerClass)
#endif

#endif /* LeakDetector_h */
