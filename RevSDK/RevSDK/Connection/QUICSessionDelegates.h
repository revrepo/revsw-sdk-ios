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

namespace rs
{
    class QUICSession;
    
    class QUICStreamDelegate
    {
    public:
        QUICStreamDelegate() {}
        virtual ~QUICStreamDelegate() {}
        virtual void quicSessionDidReceiveResponse(QUICSession* aSession,
                                                   net::QuicDataStream* aStream,
                                                   const net::SpdyHeaderBlock& aHedaers,
                                                   int aCode) = 0;
        virtual void quicSessionDidReceiveData(QUICSession* aSession,
                                               net::QuicDataStream* aStream,
                                               const char* aData, size_t aLen) = 0;
        virtual void quicSessionDidFinish(QUICSession* aSession,
                                          net::QuicDataStream* aStream) = 0;
        virtual void quicSessionDidFail(QUICSession* aSession,
                                        net::QuicDataStream* aStream) = 0;
    };
    
    class QUICSessionDelegate
    {
    public:
        QUICSessionDelegate() {}
        virtual ~QUICSessionDelegate() {}
        virtual void quicSessionDidChangeState(QUICSession* aSession, bool aConnected) = 0;
    };
}
