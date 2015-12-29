//
//  Network.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/23/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef Network_hpp
#define Network_hpp

#include <stdio.h>
#include <iostream>

namespace rs
{
    class Data;
    class Error;
    class NativeNetwork;
    
    class Network
    {
        NativeNetwork* nativeNetwork;
        
        void performRequest(std::string aURL, std::function<void(const Data&, const Error&)> aCompletionBlock);
        void performRequest(std::string aURL, const Data& aBody, std::function<void(const Data&, const Error&)> aCompletionBlock);
        
        std::string mStatsReportingURL;
        
        public:
        
        Network();
        ~Network();
        
        void loadConfiguration(const std::string &, std::function<void(const Data&, const Error&)> aCompletionBlock);
        void sendStats(const Data&, std::function<void(const Error&)>);
        
        void setStatsReportingURL(const std::string& aStatsReportingURL) { mStatsReportingURL = aStatsReportingURL; };
    };
}

#endif /* Network_hpp */
