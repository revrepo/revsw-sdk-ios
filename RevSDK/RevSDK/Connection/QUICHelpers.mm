//
//  QUICHelpers.cpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSNativeUDPSocketWrapper.h"
#include <iostream>

#include "QUICHelpers.h"

using namespace rs;
using namespace net;
using namespace net::tools;

CocoaQuicPacketWriter::CocoaQuicPacketWriter(NativeUDPSocketWrapper *cocoaUDPSocketDelegate) :
socketOwner(cocoaUDPSocketDelegate)
{
    
}

net::WriteResult CocoaQuicPacketWriter::WritePacket(const char* buffer, size_t buf_len,
                                                    const net::IPAddressNumber &self_address,
                                                    const net::IPEndPoint &peer_address)
{
    if (this->socketOwner->blocked)
    {
        return net::WriteResult(WRITE_STATUS_BLOCKED, 0);
    }
    
    [this->socketOwner->udpSocket sendData:[NSData dataWithBytes:buffer length:buf_len]
                               withTimeout:0
                                       tag:0];
    
    return WriteResult(WRITE_STATUS_OK, buf_len);
}

bool CocoaQuicPacketWriter::IsWriteBlockedDataBuffered() const
{
    return false;
}

bool CocoaQuicPacketWriter::IsWriteBlocked() const
{
    return this->socketOwner->blocked;
}

void CocoaQuicPacketWriter::SetWritable()
{
    this->socketOwner->blocked = true;
}

QuicByteCount CocoaQuicPacketWriter::GetMaxPacketSize(const IPEndPoint& peer_address) const
{
    // 576 the maximum IP packet size which IPv4 guarantees will be supported
    // For IPv6, the guaranteed size is 1280
    // The theoretical limit for the maximum size of a UDP packet is 65507
    return 65507;
}
