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
#include "RevProofVerifier.h"
#include "RSUDPService.h"

namespace rs
{
    class QuicConnectionHelper : public net::QuicConnectionHelperInterface
    {
    public:
        class DummyAlarm : public net::QuicAlarm
        {
        public:
            DummyAlarm(net::QuicAlarm::Delegate *delegate) : net::QuicAlarm(delegate) {}
        protected:
            virtual void SetImpl() override {}
            virtual void CancelImpl() override {}
        };
        
        QuicConnectionHelper() {}
        
        virtual const net::QuicClock *GetClock() const override
        { return &this->clock; }
        
        virtual net::QuicRandom *GetRandomGenerator() override
        { return net::QuicRandom::GetInstance(); }
        
        virtual net::QuicAlarm *CreateAlarm(net::QuicAlarm::Delegate *delegate) override
        { return new DummyAlarm(delegate); /* deleted by the caller */ }
        
        net::QuicClock clock;
    };
    
    class CocoaQuicPacketWriter : public net::QuicPacketWriter
    {
    public:
        
        explicit CocoaQuicPacketWriter(UDPService *cocoaUDPSocketDelegate);
        
        virtual net::WriteResult WritePacket(const char *buffer, size_t buf_len,
                                             const net::IPAddressNumber& self_address,
                                             const net::IPEndPoint &peer_address) override;
        virtual bool IsWriteBlockedDataBuffered() const override;
        virtual bool IsWriteBlocked() const override;
        virtual void SetWritable() override;
        
    public:
        
        UDPService* socketOwner;
    };
    
    class CocoaWriterFactory : public net::QuicConnection::PacketWriterFactory
    {
    public:
        
        CocoaWriterFactory(net::QuicPacketWriter *targetWriter) :
        writer(targetWriter) {}
        
        ~CocoaWriterFactory() override {}
        
        net::QuicPacketWriter *Create(net::QuicConnection *connection) const override
        { return this->writer; }
        
    private:
        
        net::QuicPacketWriter *writer;
    };
}