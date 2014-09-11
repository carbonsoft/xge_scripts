#!/bin/bash
. /cfg/config

declare -A qos
H=${qos['root_rate']:-850000}
R=${qos['reserved']}

if [ -z "$R" ]; then
	R=$((H*5/100))
	[ "$R" -gt 20000 ] && R=20000
fi
H=$((H-R))

# pfifo меньше грузит чем pfifo_fast
ip a| grep ': eth' |cut -d ':' -f 2 | while read dev; do tc qdisc del dev "$dev" root; tc qdisc add dev "$dev" root pfifo; done

ip link set dev imq0 down
ip link set dev imq1 down
ip link set dev imq0 up
ip link set dev imq1 up


set_imq(){
local dev=$1
tc qdisc del dev $dev root 2>/dev/null
tc qdisc add dev $dev root handle 1: htb 

quantum=$((H*1000/80))
[ "$quantum" -gt 200000 ] && quantum=200000
[ "$quantum" -lt 1500   ] && quantum=1500
tc class replace dev $dev parent 1: classid 1:1 htb rate ${H}kbit ceil ${H}kbit quantum $quantum
# подкласс для шейперов абонентов
tc class replace dev $dev parent 1:1 classid 1:100 htb rate $((H/6))kbit ceil ${H}kbit prio 0

# подкласс для суммарано локалного трафика
tc class replace dev $dev parent 1:1 classid 1:200 htb rate ${qos['local_rate']:-50000}kbit ceil ${qos['local_ceil']:-500000}kbit prio 0
tc qdisc replace dev $dev parent 1:200 handle 200: pfifo
tc filter add dev $dev parent 1: protocol ip prio 1 handle 200 fw flowid 1:200

# подкласс для суммарно города
tc class replace dev $dev parent 1:1 classid 1:300 htb rate ${qos['city_rate']:-50000}kbit ceil ${qos['city_ceil']:-500000}kbit prio 0
tc qdisc replace dev $dev parent 1:300 handle 300: pfifo
tc filter add dev $dev parent 1: protocol ip prio 1 handle 300 fw flowid 1:300
}

set_imq imq0
set_imq imq1
