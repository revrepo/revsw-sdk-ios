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

CocoaQuicPacketWriter::CocoaQuicPacketWriter(UDPService *cocoaUDPSocketDelegate) :
socketOwner(cocoaUDPSocketDelegate)
{
    
}

net::WriteResult CocoaQuicPacketWriter::WritePacket(const char* buffer, size_t buf_len,
                                                    const net::IPAddressNumber &self_address,
                                                    const net::IPEndPoint &peer_address)
{
    if (!socketOwner->connected())
    {
        return net::WriteResult(WRITE_STATUS_BLOCKED, 0);
    }
    
    bool ok = socketOwner->send(buffer, buf_len);
    
    return WriteResult(ok ? WRITE_STATUS_OK : WRITE_STATUS_ERROR, buf_len);
}

bool CocoaQuicPacketWriter::IsWriteBlockedDataBuffered() const
{
    return false;
}

bool CocoaQuicPacketWriter::IsWriteBlocked() const
{
    return !socketOwner->connected();
}

void CocoaQuicPacketWriter::SetWritable()
{
    std::cout << "CocoaQuicPacketWriter::SetWritable - WTF?" << std::endl;
}
