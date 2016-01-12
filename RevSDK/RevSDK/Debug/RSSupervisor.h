//
//  RSSupervisor.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/12/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

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
