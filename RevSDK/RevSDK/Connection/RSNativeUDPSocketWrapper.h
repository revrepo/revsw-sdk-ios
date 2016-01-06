//
//  RSNativeUDPSocketWrapper.h
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

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