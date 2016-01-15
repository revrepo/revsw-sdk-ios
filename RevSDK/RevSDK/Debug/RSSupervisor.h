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

#include <atomic>

namespace rs
{
    class RSSupervisor
    {
    public:
    private:
    };
    
    template <class T>
    class RSTrackable
    {
    public:
        RSTrackable(): mTrackId(mTrackCounter++) {}
        virtual ~RSTrackable() {}
        int trackId() const { return mTrackId; }
    private:
        int mTrackId;
        static std::atomic<int> mTrackCounter;
    };
}
