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

#pragma once

#include "QUICHeaders.h"
#include "Data.hpp"
#include "Error.hpp"

namespace rs
{
    class QUICDataStream: public net::tools::QuicSpdyClientStream
    {
    public:
        class VisitorProxy: public net::QuicDataStream::Visitor
        {
        public:
            VisitorProxy():mOwner(nullptr) {}
            ~VisitorProxy() {}
            
            void setOwner(QUICDataStream* aOwner) { mOwner = aOwner; }
            
            void OnClose(QuicDataStream* stream) override
            {
                if (mOwner != nullptr)
                    mOwner->onVisitorSentClose();
            }
        private:
            QUICDataStream* mOwner;
        };
        
        friend class VisitorProxy;
    public:
        class Delegate
        {
        public:
            Delegate() {}
            virtual ~Delegate() {}
            
            virtual void onQUICStreamReceivedData(QUICDataStream* aStream, const char* aData, size_t aDataLen) = 0;
            virtual void onQUICStreamReceivedResponse(QUICDataStream* aStream, int aCode, const net::SpdyHeaderBlock& aHeaders) = 0;
            virtual void onQUICStreamFailed(QUICDataStream* aStream, Error aError) = 0;
            virtual void onQUICStreamCompleted(QUICDataStream* aStream) = 0;
            
        };
    public:
        QUICDataStream(net::QuicStreamId id, net::tools::QuicClientSession* session);
        ~QUICDataStream() override;
        
        void setDelegate(Delegate* aDelegate) { mDelegate = aDelegate; }
        
        void update(size_t aNowMS);
        
        void onSocketError(Error aError);
        
        const Error error() const { return mError; }
        
    protected:
        
        uint32 ProcessData(const char* data, uint32 data_len) override;
        void OnStreamHeadersComplete(bool fin, size_t frame_len) override;
        void onVisitorSentClose();
        
    private:
        Delegate* mDelegate;
        VisitorProxy mVisitorProxy;
        size_t mInitialMS;
        size_t mTimeoutMS;
        bool mFailed;
        bool mHeadersDelivered;
        Data mCache;
        Error mError;
    };
}
