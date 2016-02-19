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

#import "RSNativeUDPSocketWrapper.h"
#import "RSLog.h"
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
    
    self->blocked = false;
    self->mDelegate = aDelegate;
    self->udpSocket = [[RevAsyncUdpSocket alloc] initWithDelegate:self];
    [self->udpSocket setMaxReceiveBufferSize:256000];
    [self->udpSocket setRunLoopModes:@[NSRunLoopCommonModes]];
    
    NSError *error = nil;
    
    if (! [self->udpSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connectToHost: %@", error);
        return nil;
    }
    
    [self->udpSocket receiveWithTimeout:-1 tag:0];
    
    //NSLog(@"Ready");
    return self;
}

#pragma mark - AsyncUdpSocketDelegate

- (void)onUdpSocket:(RevAsyncUdpSocket *)sock
 didSendDataWithTag:(long)tag
{
    self->blocked = false;
    //NSLog(@">>> outgoing ok");
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
    rs::Log::info(rs::kLogTagUDPData, "socket received data %ld from host %s timestamp %lld", data.length, host.UTF8String, RSTimeStamp);
    
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
    rs::Log::error(rs::kLogTagUDPData, "socket did not receive data %S timestamp %lld", error.description.UTF8String, RSTimeStamp);
    
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
