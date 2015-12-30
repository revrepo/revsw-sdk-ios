//
//  QUICHelpers.cpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSNativeUDPSocketWrapper.h"

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
    
    BOOL sendResult =
    [this->socketOwner->udpSocket sendData:[NSData dataWithBytes:buffer length:buf_len]
                               withTimeout:0
                                       tag:0];
    
    if (sendResult)
    {
        //NSLog(@">> outgoing %zu", buf_len);
    }
    else
    {
        NSLog(@"! WritePacket error! ");
    }
    
    this->socketOwner->blocked = sendResult;
    return WriteResult(sendResult ? WRITE_STATUS_OK : WRITE_STATUS_ERROR, buf_len);
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
