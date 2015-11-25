//
//  Model.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Model_hpp
#define Model_hpp

#include <stdio.h>
#include <memory>

namespace rs
{
    class Protocol;
    class Connection;
    class Network;
    class DataStorage;
    class Configuration;
    class Timer;
    
    class Model
    {
      Timer* mConfigurationRefreshTimer;
      Network* mNetwork;
      DataStorage* mDataStorage;
      std::shared_ptr<Configuration> mConfiguration;
        
      public:
        
        Model();
        
        static Model* instance();
        
        std::shared_ptr<Protocol> currentProtocol();
        std::shared_ptr<Connection> currentConnection();
        
        void loadConfiguration();
        void initialize();
    };
}

#endif /* Model_hpp */
