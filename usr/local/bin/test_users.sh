#/bin/bash

##. /etc/rc.d/init.d/functions

TMP_DIR=/tmp/users_test
mkdir -p $TMP_DIR

OUTPUT_SHAPERS=$TMP_DIR/outputh_shaper.imq0
INPUT_SHAPERS=$TMP_DIR/input_shaper.imq1
SNAT_TREE=$TMP_DIR/snat_tree
SESSION_DUMP=$TMP_DIR/session_dump
TMP_OUT=$TMP_DIR/out



prepare() {
	tc -s -s class show dev imq0 | sed -e 's/Kbit/000bit/g; s/Mbit/000000bit/g' > $INPUT_SHAPERS
	tc -s -s class show dev imq1 | sed -e 's/Kbit/000bit/g; s/Mbit/000000bit/g' > $OUTPUT_SHAPERS
	iptables-save -t nat | grep "j SNAT" | grep "xge_user.*snat.*" > $SNAT_TREE
	xgesh session dump > $SESSION_DUMP
}

user_shaper() {
	direction=$1
	class=$2

	[ "${class:--}" == "-" ] && return 0

	[ "$direction" == "input" ] && shapers=$INPUT_SHAPERS
	[ "$direction" == "output" ] && shapers=$OUTPUT_SHAPERS

	kernel_speed="$( grep -A 4 "class.*$class" $shapers | grep leaf | sed -e 's/class.*parent.*leaf.*prio\s.*rate/rate/g' | cut -d ' ' -f 2,4,6)"
	bytes_and_pkt="$( grep -A 4 "class.*$class" $shapers | grep pkt | awk '{print $2$3}' )"
	current_rate="$( grep -A 4 "class.*$class" $shapers | grep -v ceil | grep rate | cut -d ' ' -f 3 )"
	
	echo "$kernel_speed $current_rate $bytes_and_pkt"
}

snat_from_kernel() {
	ip=$1
	grep ${ip}/32 $SNAT_TREE | cut -d ' ' -f 8
}

print_session_info() {
		local ip=$1
		local session_snat=$2
		local session_class_id=$3
		local session_rates=$4

		read _in session_rate_in session_ceil_in session_burst_in _out session_rate_out session_ceil_out session_burst_out  <<< "$( echo $session_rates | tr "|" " " | sed -e 's/[[:digit:]]\+/&000bit/g' )"
		echo -e "$ip session: snat: $session_snat class_id: $session_class_id | rate_in: $session_rate_in ceil_in: $session_ceil_in | rate_out: $session_rate_out ceil_out: $session_ceil_out"
}

print_kernel_info() {
		local ip=$1
		local kernel_class_id=$2

		kernel_snat="$( snat_from_kernel $ip )"
		read kernel_rate_in kernel_ceil_in kernel_burst_in current_rate_in current_total tmp <<< "$( user_shaper input ${kernel_class_id:--} )"
		read kernel_rate_out kernel_ceil_out kernel_burst_out current_rate_out current_total tmp <<< "$( user_shaper output ${kernel_class_id:--} )"
		echo -e "${ip:--} kernel: snat: ${kernel_snat:--} class_id: ${kernel_class_id:--} | rate_in: ${kernel_rate_in:--} ceil_in: ${kernel_ceil_in:--} | rate_out: ${kernel_rate_out:--} ceil_out: ${kernel_ceil_out:--}"
}

print_current_info() {
	local ip=$1
	local class_id=$2

	read current_rate_in current_total_in <<< "$( user_shaper input ${class_id:--} | cut -d ' ' -f 4- )"
	read current_rate_out current_total_out <<< "$( user_shaper output ${class_id:--} | cut -d ' ' -f 4- )"
	local current_arp="$( grep "${ip} " $ARP_TABLE | sed -e 's/ \+/ /g' )"

	echo -e "${ip:--} current: rate_in: ${current_rate_in:--} tital_in: ${current_total_in:--} | rate_out: ${current_rate_out:--} total_out: ${current_total_out:--}"
}



main(){
	prepare
	cat $SESSION_DUMP | while read ip session_login session_snat session_rates session_lists smh session_class_id tmp; do
		print_session_info $ip $session_snat $session_class_id $session_rates
		print_kernel_info $ip $session_class_id
		print_current_info $ip $session_class_id
		echo
	done > $TMP_OUT
	cat $TMP_OUT | sed -e 's/ rate_in:/\trate_in:/g'

}

 main "$@"
