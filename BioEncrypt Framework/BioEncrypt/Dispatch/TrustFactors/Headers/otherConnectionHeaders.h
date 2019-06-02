/*
 * Original struct definitions by Apple, modified by AR on 7/24/2014
 */

/*
 * Copyright (c) 2010-2013 Apple Inc. All rights reserved.
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
 * Copyright (c) 1982, 1986, 1990, 1993
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


#import <Foundation/Foundation.h>

#import <sys/sysctl.h>
#include <sys/param.h>
#include <sys/queue.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#ifdef INET6
#include <netinet/ip6.h>
#endif /* INET6 */
#include <netinet/tcp.h>

#if TARGET_IPHONE_SIMULATOR
#include <sys/socketvar.h>
#include <net/route.h>
#include <netinet/in_pcb.h>
#include <netinet/ip_icmp.h>
#include <netinet/icmp_var.h>
#include <netinet/igmp_var.h>
#include <netinet/ip_var.h>
#include <netinet/tcp.h>
#include <netinet/tcpip.h>
#include <netinet/tcp_seq.h>
#define TCPSTATES
#include <netinet/tcp_fsm.h>
#include <netinet/tcp_var.h>
#include <netinet/udp.h>
#include <netinet/udp_var.h>
#else
#include "socketvar.h"
#include "route.h"
#include "in_pcb.h"
#include "ip_icmp.h"
#include "icmp_var.h"
#include "igmp_var.h"
#include "ip_var.h"
#include "tcpip.h"
#include "tcp_seq.h"
#define TCPSTATES
#include "tcp_fsm.h"
#include "tcp_var.h"
#include "udp.h"
#include "udp_var.h"
#endif

#include <arpa/inet.h>
#include <err.h>
#include <errno.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include "netstat.h"

/* definitions */
#define USE_NSLOG 1 // Set to 0 to turn off
#define USE_NSMUTABLESTRING 0
#define SO_TC_MAX 10 // manually added b/c doesn't appear to be in sys/socket.h
extern char *tcpstates[];

#define ROUNDUP64(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(UInt64) - 1))) : sizeof(UInt64))
#define ADVANCE64(x, n) (((char *)x) += ROUNDUP64(n))

#ifdef __arm64__
//typedef SInt32   inp_gen_t;
#else
typedef u_quad_t inp_gen_t;
#endif
typedef u_quad_t so_gen_t;

struct xtcpcb_n {
    UInt32       xt_len;
    UInt32       xt_kind;                    // XSO_TCPCB
    
    UInt64       t_segq;
    SInt32             t_dupacks;                  // Consecutive dup acks recd.
    
#define TCPT_NTIMERS_EXT 4                  // <netinet/tcp_timer.h>
    SInt32             t_timer[TCPT_NTIMERS_EXT];  // TCP timers.
#undef TCPT_NTIMERS_EXT
    
    SInt32             t_state;                    // State of this connection.
    UInt32           t_flags;
    
    SInt32             t_force;
    
    tcp_seq         snd_una;                    // Send unacknowledged.
    tcp_seq         snd_max;                    // Highest sequence number sent used to recognize retransmits.
    
    tcp_seq         snd_next;                   // Send next.
    tcp_seq         snd_up;                     // Send urgent pointer.
    
    tcp_seq         snd_wl1;                    // Window update seg seq number.
    tcp_seq         snd_wl2;                    // Window update seg ack number.
    tcp_seq         iss;                        // Initial send sequence number.
    tcp_seq         irs;                        // Initial receive sequence number.
    
    tcp_seq         rcv_nxt;                    // Receive next.
    tcp_seq         rcv_adv;                    // Advertised window.
    UInt32       rcv_wnd;                    // Receive window.
    tcp_seq         rcv_up;                     // Receive urgent pointer.
    
    UInt32       snd_wnd;                    // Send window.
    UInt32       snd_cwnd;                   // Congestion-controlled window.
    UInt32       snd_ssthresh;               // snd_cwnd size threshold for slow start exponential to linear switch.
    
    UInt32           t_maxopd;                   // mss plus option.
    
    UInt32       t_rcvtime;                  // Time at which a packet was received.
    UInt32       t_starttime;                // Time connection was established.
    SInt32             t_rtttime;                  // Round trip time.
    tcp_seq         t_rtseq;                    // Sequence number being timed.
    
    SInt32             t_rxtcur;                   // Current retransmit value (ticks).
    UInt32           t_maxseg;                   // Maximum segment size.
    SInt32             t_srtt;                     // Smoothed round-trip time.
    SInt32             t_rttvar;                   // Variance in round-trip time.
    
    SInt32             t_rxtshift;                 // log(2) of rexmt exp. backoff.
    UInt32           t_rttmin;                   // Minimum rtt allowed.
    UInt32       t_rttupdated;               // Number of times rtt sampled.
    UInt32       max_sndwnd;                 // Largest window peer has offered.
    
    SInt32             t_softerror;                // Possible error not yet reported.
    // Out-of-band data
    SInt8            t_oobflags;                 // Have some.
    SInt8            t_iobc;                     // Input character.
    UInt8          snd_scale;                  // Window scaling for send window.
    UInt8          rcv_scale;                  // Window scaling for recv window.
    UInt8          request_r_scale;            // Pending window scaling.
    UInt8          requested_s_scale;
    UInt32       ts_recent;                  // Timestamp echo data.
    
    UInt32       ts_recent_age;              // When last updated.
    tcp_seq         last_ack_sent;
    // RFC 1644 variables.
    tcp_cc          cc_send;                    // Send connection count.
    tcp_cc          cc_recv;                    // Receive connection count.
    tcp_seq         snd_recover;                // For use in fast recovery.
    // Experimental.
    UInt32       snd_cwnd_prev;              // cwnd prior to retransmit.
    UInt32       snd_ssthresh_prev;          // ssthresh prior to rentransmit.
    UInt32       t_badrxtwin;                // Window for retransmit recovery.
};

struct xinpcb_n {
    UInt32   xi_len;     // Length of this structure.
    UInt32   xi_kind;    // XSO_INPCB
    UInt64   xi_inpp;
    UInt16     inp_fport;  // Foreign port.
    UInt16     inp_lport;  // Local port.
    UInt64   inp_ppcb;   // Pointer to per-protocol PCB.
    inp_gen_t   inp_gencnt; // Generation count of this instance.
    SInt32         inp_flags;  // Generic IP/datagram flags.
    UInt32   inp_flow;
    UInt8      inp_vflag;
    UInt8      inp_ip_ttl; // Time to live.
    UInt8      inp_ip_p;   // Protocol.
    union {
        struct  in_addr_4in6    inp46_foreign;
        struct  in6_addr        inp6_foreign;
    } inp_dependfaddr;
    union {
        struct  in_addr_4in6    inp46_local;
        struct  in6_addr        inp6_local;
    } inp_dependladdr;
    struct {
        UInt8  inp4_ip_tos; // Type of service.
    } inp_depend4;
    struct {
        UInt8    inp6_hlim;
        SInt32         inp6_cksum;
        UInt16     inp6_ifindex;
        SInt16       inp6_hops;
    } inp_depend6;
    UInt32   inp_flowhash;
};


#define SO_TC_STATS_MAX 4

struct data_stats {
    UInt64      rxpackets;
    UInt64      rxbytes;
    UInt64      txpackets;
    UInt64      txbytes;
};

struct xgen_n {
    UInt32   xgn_len;    // Length of this structure.
    UInt32   xgn_kind;   // Number of PCBs at this time.
};

#define XSO_SOCKET	0x001
#define XSO_RCVBUF	0x002
#define XSO_SNDBUF	0x004
#define XSO_STATS	0x008
#define XSO_INPCB	0x010
#define XSO_TCPCB	0x020

struct xsocket_n {
    UInt32      xso_len;    // Length of this structure.
    UInt32      xso_kind;   // XSO_SOCKET
    UInt32      xso_so;     // Makes a convenient handle.
    SInt16      so_type;
    UInt32      so_options;
    SInt16      so_linger;
    SInt16      so_state;
    UInt64      so_pcb;     // Another convenient handle.
    SInt32      xso_protocol;
    SInt32      xso_family;
    SInt16      so_qlen;
    SInt16      so_incqlen;
    SInt16      so_qlimit;
    SInt16      so_timeo;
    UInt16      so_error;
    pid_t       so_pgid;
    UInt32      so_oobmark;
    uid_t       so_uid;     // XXX
};

struct xsockbuf_n {
    UInt32      xsb_len;    // Length of this structure.
    UInt32      xsb_kind;   // XSO_RCVBUF or XSO_SNDBUF.
    UInt32      sb_cc;
    UInt32      sb_hiwat;
    UInt32      sb_mbcnt;
    UInt32      sb_mbmax;
    SInt32      sb_lowat;
    SInt16      sb_flags;
    SInt16      sb_timeo;
};

struct xsockstat_n {
    UInt32      xst_len;    // Length of this structure.
    UInt32      xst_kind;   // XSO_STATS
#define SO_TC_STATS_MAX 4
    struct data_stats   xst_tc_stats[SO_TC_STATS_MAX];
};

#define ALL_XGN_KIND_INP (XSO_SOCKET | XSO_RCVBUF | XSO_SNDBUF | XSO_STATS | XSO_INPCB)
#define ALL_XGN_KIND_TCP (ALL_XGN_KIND_INP | XSO_TCPCB)