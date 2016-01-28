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
        virtual void wasRedirected(void*, void* );
        
    private:
       
       void* mHolder;
       std::shared_ptr<Request> mCurrentRequest;
       std::shared_ptr<Response> mResponse;
       ConnectionDelegate* mConnectionDelegate;
    };
}

#endif /* StandardConnection_hpp */
