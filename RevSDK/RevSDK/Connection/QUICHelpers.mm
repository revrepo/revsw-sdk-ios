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
