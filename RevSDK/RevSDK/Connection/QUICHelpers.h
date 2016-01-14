//
//  QUICHelpers.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#pragma once

#include "QUICHeaders.h"
#include "RevProofVerifier.h"

@class NativeUDPSocketWrapper;

namespace rs
{
    class SimpleBufferAllocator : public net::QuicBufferAllocator
    {
    public:
        char* New(size_t size) override
        { return new char[size]; }
        
        void Delete(char* buffer) override
        { delete[] buffer; }
    };
    
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
        
        virtual net::QuicBufferAllocator* GetBufferAllocator() override
        { return &this->allocator; }
        
        net::QuicClock clock;
        SimpleBufferAllocator allocator;
    };
    
    class CocoaQuicPacketWriter : public net::QuicPacketWriter
    {
    public:
        
        static NativeUDPSocketWrapper* createNativeSocket();
        
        explicit CocoaQuicPacketWriter(NativeUDPSocketWrapper *cocoaUDPSocketDelegate);
        
        virtual net::WriteResult WritePacket(const char *buffer, size_t buf_len,
                                             const net::IPAddressNumber& self_address,
                                             const net::IPEndPoint &peer_address) override;
        virtual bool IsWriteBlockedDataBuffered() const override;
        virtual bool IsWriteBlocked() const override;
        virtual void SetWritable() override;
        virtual net::QuicByteCount GetMaxPacketSize(const net::IPEndPoint& peer_address) const override;
        
    public:
        
        NativeUDPSocketWrapper *socketOwner;
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