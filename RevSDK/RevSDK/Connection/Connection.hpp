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

#ifndef Connection_hpp
#define Connection_hpp

#include <stdio.h>
#include <iostream>
#include <string>

namespace rs
{
    class Request;
    class Connection;
    class Response;
    class Data;
    class Error;
    
    class ConnectionDelegate
    {
    public:
        
        virtual void connectionDidReceiveResponse(std::shared_ptr<Connection> aConnection, std::shared_ptr<Response> aResponse) = 0;
        virtual void connectionDidReceiveData(std::shared_ptr<Connection> aConnection, Data aData) = 0;
        virtual void connectionDidFinish(std::shared_ptr<Connection> aConnection) = 0;
        virtual void connectionDidFailWithError(std::shared_ptr<Connection> aConnection, Error aError) = 0;
    };
    
    class Connection
    {
    private:
        // excuse https://en.wikipedia.org/wiki/Fetch-and-add#x86_implementation , should be much faster than locks
        static std::atomic<int> gLastConnectionID;
        int mConnectionID;
        
        int64_t mFirstByteReceivedTimestamp;
        
        int64_t mStartTimestamp;
        int64_t mEndTimestamp;
        
    public:
        Connection();
        
        virtual void startWithRequest(std::shared_ptr<Request>, ConnectionDelegate*) = 0;
        int          getID() { return mConnectionID;}
        
        template <class T>
        static std::shared_ptr<Connection> create()
        {
            std::shared_ptr<Connection> result(new T());
            result->mWeakThis = std::weak_ptr<Connection>(result);
            return result;
        }
        
        void addSentBytesCount(long long aCount);
        void addReceivedBytesCount(long long aCount);
        
        int64_t getTotalSent() const            { return mBytesSent; }
        int64_t getTotalReceived() const        { return mBytesReceived; }
        
        int64_t getStartTimestamp() const       { return mStartTimestamp; }
        int64_t getEndTimestamp() const         { return mEndTimestamp; }
        int64_t getFirstByteTimestamp() const   { return mFirstByteReceivedTimestamp; }
        
        void onEnd();
        void onStart();
        void onResponseReceived();
        
        std::string edgeHost() const;
        
        virtual std::string edgeTransport()const = 0;
        
        virtual void didReceiveData(void* ) = 0;
        virtual void didReceiveResponse(void* ) = 0;
        virtual void didCompleteWithError(void* ) = 0;
        
        static int getLastConnectionId();
        
    protected:
        
        std::string mEdgeHost;
        
        int64_t mBytesSent;
        int64_t mBytesReceived;
        
        std::weak_ptr<Connection> mWeakThis;
    };
}

#endif /* Connection_hpp */
