//
//  DataStorage.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/24/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef DataStorage_hpp
#define DataStorage_hpp

#include <stdio.h>
#include <string>

namespace rs
{
  class Configuration;
    
  class DataStorage
  {
     void* nativeDataStorage;
      
     public:
      
      DataStorage();
      ~DataStorage();
      
      void saveConfiguration(const Configuration&);
      Configuration configuration()const;
  };
}

#endif /* DataStorage_hpp */
