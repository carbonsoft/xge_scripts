#!/bin/bash

echo_from_arr() {
	local class
	while read class; do
		[ "$class" = root ] && continue
		echo "${arr[class]}"
	done
}

echo_classes() {
	local iface=$1
	local tmpd=/tmp/tmpfs
	local arr a b

	sed -r '
	s/^class htb 1:([0-9]+) (root|parent [0-9:]+)/\1 class add dev '$iface' \2 classid 1:\1 htb/;
	s/\/8//g;
	s/leaf [0-9:]+//;
	s/mpu 0b//g;
	s/level [0-9]+//
	' > $tmpd/classes.$$

	# fill array with classes data
	while read a b; do
		arr[a]=$b
	done < $tmpd/classes.$$

	# получаем порядок создания классов
	# и в соответствие с иерархией выводим данные из массива
	sed -r 's/^([0-9]+) .+ ((root)|parent 1:([0-9]+)).*$/\1 \3\4/' $tmpd/classes.$$ | tsort | tac | echo_from_arr

	rm -f $tmpd/classes.$$
}

main() {
	local i
	local tmpd=/tmp/tmpfs
	for i in imq1 imq0; do
		tc -d qdisc show dev $i | sed -e 's/root refcnt [0-9]* //g; s/parent [0-9]*:[0-9]* limit/limit/g' > $tmpd/qdisc.$$
		tc -d class show dev $i | sed -e 's/overhead [0-9a-f]* //g' > $tmpd/class.$$
		# tc -d qdisc show dev $i > $tmpd/qdisc.$$
		# tc -d class show dev $i > $tmpd/class.$$
		tc -d filter show dev $i > $tmpd/filter.$$

		# clear all
		echo "qdisc del dev $i root"
		# create root qdisc
		sed -nr 's/direct_packets_stat [^ ]+//;
		s/ver [^ ]+//;
		s/^qdisc htb ([0-9:]+)(.*)$/qdisc add dev '$i' root handle \1 htb\2/p' $tmpd/qdisc.$$

		# create classes
		echo_classes $i < $tmpd/class.$$

		# create  non-root qdiscs. TODO: re-create with sed, not awk !
		awk -v i=$i '
		/htb 1: / { next; }

		{
			sub(":","",$3);
			type=$2;
			handle=$3
			$1="";
			$2="";
			$3="";
			xx=$0
			sub("flows [^ ]+ ","",xx);
			if (type == "sfq")
				sub("limit [^ ]+ ","",xx);
			else
				xx=gensub("limit ([0-9]+)p","limit \\1",1,xx);
				xx=gensub("perturb ([0-9]+)sec","perturb \\1",1,xx);
				print "qdisc add dev",i,"parent 1:" handle,"handle",handle ":",type,xx
		}' $tmpd/qdisc.$$

		# remove all prio 1 filters. TODO: remove all. how ?
		# echo "filter del dev $i parent 1: prio 1"

		# add filters
		sed -r 's/^filter/filter add dev '$i'/; s/fw (handle [^ ]+)/\1 fw/' $tmpd/filter.$$
		rm -f $tmpd/{qdisc,class,filter}.$$
	done
	return 0
}

main "$@"
