//
//  QUICDataStream.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/5/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#pragma once

#include "QUICHeaders.h"
#include "Data.hpp"
#include "Error.hpp"

#include "LeakDetector.h"

namespace rs
{
    class QUICDataStream: public net::tools::QuicSpdyClientStream
    {
        REV_LEAK_DETECTOR(QUICDataStream);
        
    public:
        class VisitorProxy: public net::QuicSpdyStream::Visitor
        {
        public:
            VisitorProxy():mOwner(nullptr) {}
            ~VisitorProxy() {}
            
            void setOwner(QUICDataStream* aOwner) { mOwner = aOwner; }
            
            void OnClose(QuicSpdyStream* stream) override
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
        
        void OnStreamFrame(const net::QuicStreamFrame& frame) override;
        void OnInitialHeadersComplete(bool fin, size_t frame_len) override;
        void OnTrailingHeadersComplete(bool fin, size_t frame_len) override;
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
