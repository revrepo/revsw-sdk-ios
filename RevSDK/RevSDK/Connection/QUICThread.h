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
    private:
        struct Impl;
    private:
        Impl* mImpl;
    };
}
