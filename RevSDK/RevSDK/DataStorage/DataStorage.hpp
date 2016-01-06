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
  class Event;
    
  namespace data_storage
  {
      void initDataStorage();
      
      void saveConfiguration(const Configuration&);
      Configuration configuration();
      void saveRequestData(const Data&);
      void saveRequestDataVec(const std::vector<Data>&);
      
      void saveAvailableProtocols(std::vector<std::string> aVec);
      std::vector<std::string> restoreAvailableProtocols();
      
      std::vector<Data> loadRequestsData();
      void deleteRequestsData();
      
      void saveIntForKey(const std::string& aKey, int64_t aVal);
      int64_t getIntForKey(const std::string& aKey);
      
      void addEvent(const Event&);
      void* loadEvents();
      void deleteEvents();
  };
}

#endif /* DataStorage_hpp */
