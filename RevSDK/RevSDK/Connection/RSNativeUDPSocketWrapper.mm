//
//  RSNativeUDPSocketWrapper.m
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "RSNativeUDPSocketWrapper.h"

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
    
    self->blocked = false;
    self->mDelegate = aDelegate;
    self->udpSocket = [[RevAsyncUdpSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
    
    if (! [self->udpSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connectToHost: %@", error);
        return nil;
    }
    
    [self->udpSocket receiveWithTimeout:-1 tag:0];
    
    NSLog(@"Ready");
    return self;
}

#pragma mark - AsyncUdpSocketDelegate

- (void)onUdpSocket:(RevAsyncUdpSocket *)sock
 didSendDataWithTag:(long)tag
{
    self->blocked = false;
    NSLog(@">>> outgoing ok");
}

- (void)onUdpSocket:(RevAsyncUdpSocket *)sock
didNotSendDataWithTag:(long)tag
         dueToError:(NSError *)error
{
    self->blocked = false;
    NSLog(@"!! outgoing error %@", error);
}

- (BOOL)onUdpSocket:(RevAsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    if (! self->mDelegate)
    {
        return NO;
    }
    
    net::QuicEncryptedPacket packet((const char *)data.bytes, data.length);
    if (!mDelegate->onQUICPacket(packet))
    {
        return NO;
    }
    
    [udpSocket receiveWithTimeout:-1 tag:0];
    return YES;
}

- (void)onUdpSocket:(RevAsyncUdpSocket *)sock
didNotReceiveDataWithTag:(long)tag
         dueToError:(NSError *)error
{
    NSLog(@"didNotReceiveDataWithTag dueToError %@", error);
}

- (void)onUdpSocketDidClose:(RevAsyncUdpSocket *)sock
{
    self->blocked = false;
    
    if (self->mDelegate)
    {
        self->mDelegate->onQUICError();
    }
}

@end
