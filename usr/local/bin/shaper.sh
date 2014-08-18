#!/bin/bash

TC="/sbin/tc"
IP="/sbin/ip"

ip link set dev imq0 down
ip link set dev imq1 down
ip link set dev imq0 up
ip link set dev imq1 up

#echo for i in #TODO: взять из кос.сх
#echo заменить pfifo_fast на pfifo

$TC qdisc del dev imq0 root 2>/dev/null
$TC qdisc del dev imq1 root 2>/dev/null
$TC qdisc add dev imq0 root handle 1: htb 
$TC qdisc add dev imq1 root handle 1: htb 
tc qdisc replace dev imq0 parent 1:100 handle 1:1000 2>/dev/null
tc qdisc replace dev imq1 parent 1:100 handle 1:1000 2>/dev/null
tc filter replace dev imq0 parent 1: protocol ip prio 1 handle 100 fw classid 1:100
tc filter replace dev imq1 parent 1: protocol ip prio 1 handle 100 fw classid 1:100
tc class replace dev imq0 parent 1:1 classid 1:100 htb rate 1000mbit ceil 1000mbit prio 2
tc class replace dev imq1 parent 1:1 classid 1:100 htb rate 1000mbit ceil 1000mbit prio 2
