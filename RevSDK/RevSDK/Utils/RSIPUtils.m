//
//  RSIPUtils.m
//  RevSDK
//
//  Created by Andrey Chernukha on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include <sys/types.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#import "GCDAsyncUdpSocket.h"
#import "STUNClient.h"
#import "RSReachability.h"

#import "RSIPUtils.h"

@interface RSIPUtils ()<STUNClientDelegate>

@property (nonatomic, strong) RSReachability* reachability;
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation RSIPUtils

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.reachability = [RSReachability rs_reachabilityForInternetConnection];
    }
    
    return self;
}

- (void)start
{
    [self checkIps];
    [self startTimer];

}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60
                                                  target:self
                                                selector:@selector(checkIps)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)checkIps
{
    [self checkPrivateIp];
    [self checkPublicIP];
}

- (void)checkPublicIP
{
    if (self.reachability.rs_currentReachabilityStatus != kRSNotReachable)
    {
        GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        STUNClient *stunClient = [[STUNClient alloc] init];
        [stunClient requestPublicIPandPortWithUDPSocket:udpSocket delegate:self];
    }
}

-(void)didReceivePublicIPandPort:(NSDictionary *) data
{
    NSString* ipAddress = [data objectForKey:publicIPKey];
 
    if (self.reachability.rs_currentReachabilityStatus == kRSReachableViaWiFi)
    {
        self.publicWifiIP = ipAddress;
    }
    else
    if (self.reachability.rs_currentReachabilityStatus == kRSReachableViaWWAN)
    {
        self.publicCellularIP = ipAddress;
    }
}

- (void)checkPrivateIp
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    if(!getifaddrs(&interfaces))
    {
        temp_addr = interfaces;
        
        while(temp_addr != NULL)
        {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            
            if(sa_type == AF_INET || sa_type == AF_INET6)
            {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                
                if([name isEqualToString:@"en0"])
                {
                    wifiAddress = addr;
                }
                else
                if([name isEqualToString:@"pdp_ip0"])
                {
                    cellAddress = addr;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }

        freeifaddrs(interfaces);
    }
   
    if (wifiAddress)
    {
       self.privateWiFiIP = wifiAddress;
    }
    
    if (cellAddress)
    {
       self.privateCellularIP = cellAddress;
    }
}

@end
