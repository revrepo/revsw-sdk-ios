//
//  QUICThread.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#pragma once

#include <memory>
#include <mutex>
#include <list>
#include <functional>
#include <thread>

namespace rs
{
    class QUICThread
    {
    public:
        QUICThread();
        ~QUICThread();
        void perform(std::function<void(void)> aFunc);
        void update(size_t aNowMS);
        void setUpdateCallback(std::function<void(size_t)> aUpd);
    private:
        struct Impl;
    private:
        Impl* mImpl;
        std::function<void(size_t)> mUpd;
    };
}
