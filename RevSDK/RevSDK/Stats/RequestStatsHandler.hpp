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

namespace rs
{
    class Data;
    class DataStorage;
    
    class RequestStatsHandler
    {
        DataStorage* mDataStorage;
        std::vector<Data> mRequestsDataVector;
        
    public:
        
        RequestStatsHandler(DataStorage*);
        ~RequestStatsHandler(){};
        
        void addNewRequestData(const Data&);
        Data requestsData();
    };
}

#endif /* RequestStatsHandler_hpp */
