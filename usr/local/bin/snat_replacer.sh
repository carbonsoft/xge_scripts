#!/bin/bash

. /usr/local/lib/carbon_channels_lib

main() {
	[ "${reservation:-0}" != "1" ] && return 0

	timeout=$1
	__log start snat_replacer with timeout $timeout
	while sleep $timeout; do
		__log snat_replacer new loop
		for channel in $channels_list; do
			check_and_fix_channel $channel
		done
	done
}

main "$@"