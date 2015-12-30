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
    
  namespace data_storage
  {
      void initDataStorage();
      
      void saveConfiguration(const Configuration&);
      Configuration configuration();
      void saveRequestData(const Data&);
      void saveRequestDataVec(const std::vector<Data>&);
      
      std::vector<Data> loadRequestsData();
      void deleteRequestsData();
  };
}

#endif /* DataStorage_hpp */
