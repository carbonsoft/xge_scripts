#!/bin/bash

# set -eu

usage() {
	echo 'Usage: '
	echo "	$0 <IP>"
	exit 1
}

ip2mark() {
	[ "$#" = '0' ] && return 1
	local ip=( ${1//./ } )
	echo $((${ip[3]}*256*256*256+${ip[2]}*256*256+${ip[1]}*256+${ip[0]}))
}

get_shaper_by_ip() {
	printf "0x%x\n" "$(ip2mark $IP)"
}

show_ipset() {
	echo -n "ipset -o save -l | grep -w $IP >> "
	ipset -o save -l | grep -w $IP | awk '{print $2}'  | xargs
}

show_nat() {
	echo  -n "iptables-save --table=nat | grep -w $IP >> "
	iptables-save --table=nat | grep -w "$IP"
}

show_filter() {
	[ -z "$shaper" ] && echo "${FUNCNAME} >> Skip tc filter, no shaper" && return 0
	echo -n "tc filter show dev imq0 | grep $shaper >> "
	tc filter show dev imq0 | grep $shaper || echo 'Nothing'
	echo -n "tc filter show dev imq1 | grep $shaper >> "
	tc filter show dev imq1 | grep $shaper || echo 'Nothing'
}

classid_by_filter() {
	tc filter show dev $1 | grep $shaper | sed -e 's/.*classid \([0-9]*:[0-9]*\)/\1/g' | tr -d ' '
}

show_rate() {
	[ -z "$imq0_class" -a -z "$imq1_class" ] && echo "${FUNCNAME} >> Skip rate, no imq0_class" && return 0
	echo -n "imq0 rate $imq0_class (output): >> "
	tc -s -s class show dev imq0 | grep -A 2 $imq0_class | grep rate.*backlog.*requeues || echo 'Nothing'
	echo -n "imq1 rate $imq1_class (input ): >> "
	tc -s -s class show dev imq1 | grep -A 2 $imq1_class | grep rate.*backlog.*requeues || echo 'Nothing'
}

show_class() {
	[ -z "$imq0_class" -a -z "$imq1_class" ] && echo "${FUNCNAME} >> Skip tc class, no imq0/1_class" && return 0
	echo -n "tc class show dev imq0 | grep -w $imq0_class >> "
	tc class show dev imq0 | grep -w $imq0_class || echo 'Nothing'
	echo -n "tc class show dev imq1 | grep -w $imq1_class >> "
	tc class show dev imq1 | grep -w $imq1_class || echo 'Nothing'
}

show_qdisc() {
	[ -z "$imq0_class" -a -z "$imq1_class" ] && echo "${FUNCNAME} >> Skip tc qdisc, no imq0/1_class" && return 0
	echo -n "tc qdisc show dev imq0 | egrep -w $imq0_class >> " 
	tc qdisc show dev imq0 | grep -w "$imq0_class" || echo 'Nothing'
	echo -n "tc qdisc show dev imq1 | grep -w $imq1_class >> "
	tc qdisc show dev imq1 | grep -w "$imq1_class" || echo 'Nothing'

}

show_device() {
	echo -n "ip a | grep -w $IP >> "
	ip a | grep -w $IP || echo 'Nothing'
}

main() {
	IP=$1
	[ -z "$IP" ] && usage

	shaper=$(get_shaper_by_ip $@)
	imq0_class=$(classid_by_filter imq0)
	imq1_class=$(classid_by_filter imq1)

	show_ipset
	show_nat
	show_filter
	show_qdisc
	show_class
	show_rate
	show_device $1
}

main $@
