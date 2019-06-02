/*
 * Original method implementations by Apple (inet.c); modified by AR on 7/24/2014
 */

/*
 * Copyright (c) 2008 Apple Inc. All rights reserved.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 *
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */
/*
 * Copyright (c) 1983, 1988, 1993, 1995
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

//
//  ActiveConnection.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import "BETrustFactorDataset_Netstat.h"

// Connection object
#import "ActiveConnection.h"

// Netstat headers
#import "bsd_var.h"
#import <arpa/inet.h>
#import <sys/sysctl.h>
#import <netdb.h>

// Interface byte count headers
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

typedef enum {
    CONNECTION_TYPE_TCP4,
    CONNECTION_TYPE_UDP4
} ConnectionType_t;

@implementation BETrustFactorDataset_Netstat


+ (NSArray *) getTCPConnections {
    return [self getActiveConnectionsOfType:CONNECTION_TYPE_TCP4];
}


+ (NSArray*)getActiveConnectionsOfType:(ConnectionType_t)connectionType
{
    uint32_t            proto;
    char                *mib;
    char                *buf, *next;
    struct xinpgen      *xig, *oxig;
    struct xgen_n       *xgn;
    size_t              len;
    struct xtcpcb_n     *tp = NULL;
    struct xinpcb_n     *inp = NULL;
    struct xsocket_n    *so = NULL;
    struct xsockstat_n  *so_stat = NULL;
    int                 which = 0;
    NSMutableArray      *result = [@[] mutableCopy];
    
    switch (connectionType) {
        case CONNECTION_TYPE_TCP4:
            proto = IPPROTO_TCP;
            mib = "net.inet.tcp.pcblist_n";
            break;
        case CONNECTION_TYPE_UDP4:
            proto = IPPROTO_UDP;
            mib = "net.inet.udp.pcblist_n";
            break;
        default:
            //AMLogWarn(@"unknown connection type: %d", connectionType);
            return result;
    }
    
    if (sysctlbyname(mib, 0, &len, 0, 0) < 0)
    {
       // AMLogWarn(@"sysctlbyname() for len has failed with mib: %s.", mib);
        return result;
    }
    
    buf = malloc(len);
    if (!buf)
    {
       // AMLogWarn(@"malloc() for buf has failed with mib: %s.", mib);
        return result;
    }
    
    if (sysctlbyname(mib, buf, &len, 0, 0) < 0)
    {
       // AMLogWarn(@"sysctlbyname() for buf has failed with mib: %s.", mib);
        free(buf);
        return result;
    }
    
    // Bail-out if there is no more control block to process.
    if (len <= sizeof(struct xinpgen))
    {
        free(buf);
        return result;
    }
    
#define ROUNDUP64(a)    \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(UInt64) - 1))) : sizeof(UInt64))
    
    oxig = xig = (struct xinpgen *)buf;
    for (next = buf + ROUNDUP64(xig->xig_len); next < buf + len; next += ROUNDUP64(xgn->xgn_len))
    {
        xgn = (struct xgen_n *)next;
        if (xgn->xgn_len <= sizeof(struct xinpgen))
        {
            break;
        }
        
        if ((which & xgn->xgn_kind) == 0)
        {
            which |= xgn->xgn_kind;
            
            switch (xgn->xgn_kind) {
                case XSO_SOCKET:
                    so = (struct xsocket_n *)xgn;
                    break;
                case XSO_RCVBUF:
                    // (struct xsockbuf_n *)xgn;
                    break;
                case XSO_SNDBUF:
                    // (struct xsockbuf_n *)xgn;
                    break;
                case XSO_STATS:
                    so_stat = (struct xsockstat_n *)xgn;
                    break;
                case XSO_INPCB:
                    inp = (struct xinpcb_n *)xgn;
                    break;
                case XSO_TCPCB:
                    tp = (struct xtcpcb_n *)xgn;
                    break;
                default:
                 //   AMLogWarn(@"unknown kind %ld", (long)xgn->xgn_kind);
                    break;
            }
        }
        else
        {
            //AMLogWarn(@"got %ld twice.", (long)xgn->xgn_kind);
        }
        
        if ((connectionType == CONNECTION_TYPE_TCP4 && which != ALL_XGN_KIND_TCP) ||
            (connectionType != CONNECTION_TYPE_TCP4 && which != ALL_XGN_KIND_INP))
        {
            continue;
        }
        
        which = 0;
        
        
        // Ignore sockets for protocols other than the desired one.
        if (so->xso_protocol != (int)proto)
        {
            //    continue;
        }
        // Ignore PCBs which were freed during copyout.
        if (inp->inp_gencnt > oxig->xig_gen)
        {
            continue;
        }
        
        if ((inp->inp_vflag & INP_IPV4) == 0)
        {
            continue;
        }
        
        // Ignore when both local and remote IPs are LOOPBACK.
        if (ntohl(inp->inp_laddr.s_addr) == INADDR_LOOPBACK &&
            ntohl(inp->inp_faddr.s_addr) == INADDR_LOOPBACK)
        {
            continue;
        }
        
        /*
         * Local address is not an indication of listening socket or server socket,
         * but just rather the socket has been bound.
         * Thats why many UDP sockets were not displayed in the original code.
         */

        ActiveConnection *connection = [[ActiveConnection alloc] init];
        connection.localIP = [self ipToString:&inp->inp_laddr];
        connection.localPort = [NSNumber numberWithInt:ntohs((u_short)inp->inp_lport)];
        connection.remoteHost = [NSString stringWithFormat:@"%s",inetname(&inp->inp_faddr)];
        connection.remoteIP = [self ipToString:&inp->inp_faddr];
        connection.remotePort = [NSNumber numberWithInt:ntohs((u_short)inp->inp_fport)];
        if (connectionType == CONNECTION_TYPE_TCP4)
        {
            connection.status = [self stateToString:tp->t_state];
            connection.status = [NSString stringWithFormat:@"%@%@", connection.status, [self stateStringPostfix:tp->t_flags]];
        }
        else
        {
            connection.status = @"";
        }
        //connection.status = [self connectionStatusFromState:connection.statusString];
        
        for (NSUInteger i = 0; i < SO_TC_STATS_MAX; ++i)
        {
            connection.totalRX += so_stat->xst_tc_stats[i].rxbytes;
            connection.totalTX += so_stat->xst_tc_stats[i].txbytes;
        }
        
        [result addObject:connection];
    }
    
    free(buf);
    return result;
}

+ (NSString*)stateStringPostfix:(u_int)connectionFlags
{
    if (connectionFlags & (TF_NEEDSYN|TF_NEEDFIN))
    {
        return @"*";
    }
    
    return @"";
}


+ (NSString*)stateToString:(int)state
{
    return [NSString stringWithCString:tcpstates[state] encoding:NSASCIIStringEncoding];
}

/*
 * Construct an Internet address representation.
 * If the nflag has been supplied, give
 * numeric value, otherwise try for symbolic name.
 */
char *inetname(struct in_addr *inp)
{
    register char *cp;
    static char line[MAXHOSTNAMELEN];
    struct hostent *hp;
    struct netent *np;
    
    cp = 0;
    if (inp->s_addr != INADDR_ANY) {
        int net = inet_netof(*inp);
        int lna = inet_lnaof(*inp);
        
        if (lna == INADDR_ANY) {
            np = getnetbyaddr(net, AF_INET);
            if (np)
                cp = np->n_name;
        }
        if (cp == 0) {
            hp = gethostbyaddr((char *)inp, sizeof (*inp), AF_INET);
            if (hp) {
                cp = hp->h_name;
                //### trimdomain(cp, strlen(cp));
            }
        }
    }
    if (inp->s_addr == INADDR_ANY)
        //means it is listening
        strlcpy(line, "*", sizeof(line));
    else if (cp) {
        strncpy(line, cp, sizeof(line) - 1);
        line[sizeof(line) - 1] = '\0';
    } else {
        inp->s_addr = ntohl(inp->s_addr);
#define C(x)	((u_int)((x) & 0xff))
        snprintf(line, sizeof(line), "%u.%u.%u.%u", C(inp->s_addr >> 24),
                 C(inp->s_addr >> 16), C(inp->s_addr >> 8), C(inp->s_addr));
    }
    return (line);
}

+ (NSString*)ipToString:(struct in_addr *)in
{
    if (!in)
    {
        //AMLogWarn(@"in == NULL");
        return @"";
    }
    
    if (in->s_addr == INADDR_ANY)
    {
        return @"*";
    }
    else
    {
        //return [NSString stringWithCString:inet_ntoa(*in) encoding:NSASCIIStringEncoding];
        return [NSString stringWithCString:inet_ntoa(*in) encoding:NSASCIIStringEncoding];

    }
}

+ (NSString*)portToString:(int)port
{
    return (port == 0 ? @"*" : [NSString stringWithFormat:@"%d", port]);
}


+ (NSDictionary *)getInterfaceBytes{
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    u_int32_t WiFiSentBytes = 0;
    u_int32_t WiFiReceivedBytes = 0;
    u_int32_t WWANSentBytes = 0;
    u_int32_t WWANReceivedBytes = 0;
    u_int32_t TUNSentBytes = 0;
    u_int32_t TUNReceivedBytes = 0;
    
    if (getifaddrs(&addrs) == 0)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
#ifdef DEBUG
                const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                if(ifa_data != NULL)
                {
                    //NSLog(@"Interface name %s: sent %tu received %tu",cursor->ifa_name,ifa_data->ifi_obytes,ifa_data->ifi_ibytes);
                }
#endif
                
                // name of interfaces:
                // en0 is WiFi
                // pdp_ip0 is WWAN
                NSString *name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
                if ([name hasPrefix:@"en"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WiFiSentBytes += ifa_data->ifi_obytes;
                        WiFiReceivedBytes += ifa_data->ifi_ibytes;
                    }
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WWANSentBytes += ifa_data->ifi_obytes;
                        WWANReceivedBytes += ifa_data->ifi_ibytes;
                    }
                }
                
                if ([name containsString:@"tun"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        TUNSentBytes += ifa_data->ifi_obytes;
                        TUNReceivedBytes += ifa_data->ifi_ibytes;
                    }
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    // Convert to MB
    u_int32_t WiFiSentMB = round(WiFiSentBytes/1000000);
    u_int32_t WiFiReceivedMB = round(WiFiReceivedBytes/1000000);
    u_int32_t WWANSentMB = round(WWANSentBytes/1000000);
    u_int32_t WWANReceivedMB = round(WWANReceivedBytes/1000000);
    u_int32_t TUNSentMB = round(TUNSentBytes/1000000);
    u_int32_t TUNReceivedMB = round(TUNReceivedBytes/1000000);
    
   return @{@"WiFiSent":[NSNumber numberWithUnsignedInt:WiFiSentMB],
             @"WiFiRec":[NSNumber numberWithUnsignedInt:WiFiReceivedMB],
             @"WANSent":[NSNumber numberWithUnsignedInt:WWANSentMB],
             @"WANRec":[NSNumber numberWithUnsignedInt:WWANReceivedMB],
             @"TUNSent":[NSNumber numberWithUnsignedInt:TUNSentMB],
             @"TUNRec":[NSNumber numberWithUnsignedInt:TUNReceivedMB]};

}

@end
