//
//  StandardConnection.hpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#ifndef StandardConnection_hpp
#define StandardConnection_hpp

#include <stdio.h>

#include "Connection.hpp"

namespace rs
{
    class Data;
    class Response;
    class Error;
    
    class StandardConnection : public Connection
    {
    public:
        StandardConnection(const StandardConnection &aConnection) = delete;
        StandardConnection();
        ~StandardConnection();
        
        void startWithRequest(std::shared_ptr<Request>, ConnectionDelegate*);
        
        std::string edgeTransport()const;
        
        virtual void didReceiveData(void* );
        virtual void didReceiveResponse(void* );
        virtual void didCompleteWithError(void* );
        
    private:
       
        
       std::shared_ptr<Request> mCurrentRequest;
       std::shared_ptr<Response> mResponse;
       ConnectionDelegate* mConnectionDelegate;
    };
}

#endif /* StandardConnection_hpp */
