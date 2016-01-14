//
//  RSNativeUDPSocketWrapper.m
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSNativeUDPSocketWrapper.h"
#import "RSUtils.h"

@implementation NativeUDPSocketWrapper

- (instancetype)initWithHost:(NSString *)host
                      onPort:(UInt16)port
                    delegate:(rs::NativeUDPSocketCPPDelegate*)aDelegate;
{
    self = [super init];
    
    if (! self)
    {
        return nil;
    }
    
    self->blocked = true;
    self->mDelegate = aDelegate;
    self->udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                    delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (! [self->udpSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connectToHost: %@", error);
        return nil;
    }
    
    if (! [self->udpSocket beginReceiving:&error])
    {
        NSLog(@"Error beginReceiving: %@", error);
        return nil;
    }
    
    NSLog(@"NativeUDPSocketWrapper ready");
    return self;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@">>> didConnectToAddress ok");
    self->blocked = false;
    
    if (self->mDelegate)
    {
        self->mDelegate->onUDPSocketConnected();
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@">>> didNotConnect");

    if (self->mDelegate)
    {
        const rs::Error aError = rs::errorFromNSError(error);
        self->mDelegate->onQUICError(aError);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    self->blocked = false;
    //NSLog(@">>> outgoing ok");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    self->blocked = false;
    NSLog(@"!! outgoing error %@", error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext;
{
    if (self->mDelegate)
    {
        net::QuicEncryptedPacket packet((const char *)data.bytes, data.length);
        mDelegate->onQUICPacket(packet);
    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error;
{
    self->blocked = true;
    
    if (self->mDelegate)
    {
        const rs::Error aError = rs::errorFromNSError(error);
        self->mDelegate->onQUICError(aError);
    }
}

@end
