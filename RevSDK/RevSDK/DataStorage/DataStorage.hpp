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
