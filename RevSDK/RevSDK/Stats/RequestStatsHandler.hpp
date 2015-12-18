//
//  RequestStatsHandler.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 12/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef RequestStatsHandler_hpp
#define RequestStatsHandler_hpp

#include <stdio.h>
#include <vector>
#include <memory>

namespace rs
{
    class Data;
    class DataStorage;
    
    class RequestStatsHandler
    {
        std::weak_ptr<DataStorage> mDataStorage;
        std::vector<Data> mRequestsDataVector;
        
    public:
        
        RequestStatsHandler(std::weak_ptr<DataStorage>);
        ~RequestStatsHandler(){};
        
        void addNewRequestData(const Data&);
        Data requestsData();
        void deleteRequestsData();
    };
}

#endif /* RequestStatsHandler_hpp */
