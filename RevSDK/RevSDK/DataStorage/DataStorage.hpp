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
#include <vector>

namespace rs
{
  class Configuration;
  class Data;
    
  class DataStorage
  {
     public:
      
      DataStorage();
      ~DataStorage(){};
      
      void saveConfiguration(const Configuration&);
      Configuration configuration()const;
      void saveRequestData(const Data&);
      std::vector<Data> loadRequestsData();
      void deleteRequestsData();
  };
}

#endif /* DataStorage_hpp */
