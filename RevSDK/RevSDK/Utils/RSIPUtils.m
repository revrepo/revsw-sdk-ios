//
//  RSIPUtils.m
//  RevSDK
//
//  Created by Andrey Chernukha on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

@import Darwin.POSIX.net;

#include <sys/types.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import <sys/sysctl.h>
#include <resolv.h>
#include<unistd.h>
#include <dns.h>

#import "GCDAsyncUdpSocket.h"
#import "STUNClient.h"
#import "RSReachability.h"
#include "route.h"

#import "RSIPUtils.h"

#define CTL_NET 4

#if defined(BSD) || defined(__APPLE__)

#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

int getdefaultgateway(in_addr_t * addr)
{
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_FLAGS, RTF_GATEWAY};
    size_t l;
    char * buf, * p;
    struct rt_msghdr * rt;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i;
    int r = -1;
    if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        return -1;
    }
    if(l>0) {
        buf = malloc(l);
        if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            return -1;
        }
        for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i=0; i<RTAX_MAX; i++) {
                if(rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }
            
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sa_family == AF_INET
               && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                
                
                if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    char ifName[128];
                    if_indextoname(rt->rtm_index,ifName);
                    
                    if(strcmp("en0",ifName)==0){
                        
                        *addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                        r = 0;
                    }
                }
            }
        }
        free(buf);
    }
    return r;
}

#endif

@interface RSIPUtils ()<STUNClientDelegate>

@property (nonatomic, strong) RSReachability* reachability;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, copy, readwrite) NSString* publicWifiIP;
@property (nonatomic, copy, readwrite) NSString* publicCellularIP;
@property (nonatomic, copy, readwrite) NSString* privateWiFiIP;
@property (nonatomic, copy, readwrite) NSString* privateCellularIP;
@property (nonatomic, copy, readwrite) NSString* netmask;
@property (nonatomic, copy, readwrite) NSString* dns1;
@property (nonatomic, copy, readwrite) NSString* dns2;

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
    
    [self checkDNSServers];
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
    NSString *netmask = nil;
    
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
                    netmask = @(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr));
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
    
    if (netmask)
    {
        self.netmask = netmask;
    }
}

- (NSString *)gateway
{
    NSString *ipString = nil;
    struct in_addr gatewayaddr;
    int r = getdefaultgateway(&(gatewayaddr.s_addr));
    
    if(r >= 0)
    {
        ipString = [NSString stringWithFormat: @"%s",inet_ntoa(gatewayaddr)];
        NSLog(@"default gateway : %@", ipString );
    }
    else
    {
        NSLog(@"getdefaultgateway() failed");
    }
    
    return ipString;
}

- (void)checkDNSServers
{
    NSMutableArray* server_DNS = [NSMutableArray array];
    res_state res = malloc(sizeof(struct __res_state));
    int result = res_ninit(res);
    
    if(result==0)
    {
        for ( int i= 0; i < res->nscount; i++)
        {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res->nsaddr_list[i].sin_addr)];
            [server_DNS addObject:s];
        }
    }
    
    self.dns1 = server_DNS.firstObject;
    self.dns2 = server_DNS.count > 1 ? server_DNS[1] : nil;
}

@end
