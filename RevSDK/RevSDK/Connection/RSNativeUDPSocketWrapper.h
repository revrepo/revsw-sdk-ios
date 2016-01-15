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

#include "RevProofVerifier.h"
#include "RevAsyncUdpSocket.h"
#include "NativeUDPSocketCPPDelegate.h"

@interface NativeUDPSocketWrapper : NSObject <RevAsyncUdpSocketDelegate>
{
@public
    
    bool blocked;
    
    // Socket itself, owned by the wrapper.
    RevAsyncUdpSocket *udpSocket;
    
    // Client reference, a C++ object, not managed by ARC and acting as a weakref.
    rs::NativeUDPSocketCPPDelegate *mDelegate;
}

- (instancetype) __unavailable init;
- (instancetype)initWithHost:(NSString *)host
                      onPort:(UInt16)port
                    delegate:(rs::NativeUDPSocketCPPDelegate*)aDelegate;

@end
