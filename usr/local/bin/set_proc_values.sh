#!/bin/bash

set -eu

if [ "${1:-}" = 'get' ]; then
	grep "^echo.*proc" $0 | cut -d ' ' -f4 | xargs grep ''
	exit 0
fi

# arp
echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter

# route cache
echo 1 > /proc/sys/net/ipv4/route/gc_min_interval
echo 1 > /proc/sys/net/ipv4/route/gc_elasticity
echo 30 > /proc/sys/net/ipv4/route/gc_timeout
echo 10000 > /proc/sys/net/ipv4/neigh/default/gc_thresh1
echo 11000 > /proc/sys/net/ipv4/neigh/default/gc_thresh2
echo 12000 > /proc/sys/net/ipv4/neigh/default/gc_thresh3
echo 200000 > /proc/sys/net/ipv4/route/gc_thresh
echo 262144 > /proc/sys/net/ipv4/route/max_size

# conntrack
echo 15 > /proc/sys/net/netfilter/nf_conntrack_udp_timeout
echo 15 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_last_ack
echo 20 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_time_wait
echo 30 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_syn_recv
echo 60 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_fin_wait
echo 300 > /proc/sys/net/netfilter/nf_conntrack_generic_timeout
echo 262144 > /proc/sys/net/netfilter/nf_conntrack_max

# misc
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects

# option							default		custom
# /proc/sys/net/ipv4/conf/all/arp_filter			0		1
# /proc/sys/net/ipv4/route/gc_min_interval			0		1
# /proc/sys/net/ipv4/route/gc_elasticity			8		1
# /proc/sys/net/ipv4/route/gc_timeout				300		30
# /proc/sys/net/ipv4/neigh/default/gc_thresh1			128		10000
# /proc/sys/net/ipv4/neigh/default/gc_thresh2			512		11000
# /proc/sys/net/ipv4/neigh/default/gc_thresh3			1024		12000
# /proc/sys/net/ipv4/route/gc_thresh				131072		200000
# /proc/sys/net/ipv4/route/max_size				2097152		262144
# /proc/sys/net/netfilter/nf_conntrack_udp_timeout		30		15
# /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_last_ack	30		15
# /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_time_wait	120		20
# /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_syn_recv	60		30
# /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_fin_wait	120		60
# /proc/sys/net/netfilter/nf_conntrack_generic_timeout		600		300
# /proc/sys/net/netfilter/nf_conntrack_max			65536		262144
# /proc/sys/net/ipv4/conf/all/send_redirects			1		0
