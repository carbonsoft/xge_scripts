#!/bin/bash

. /usr/local/lib/carbon_channels_lib

main() {
	[ "${reservation:-0}" != "1" ] && return 0

	__log start snat_replacer with
	for channel in $channels_list; do
		__log check_and_fix_channel $channel
		check_and_fix_channel $channel
	done
}

main "$@"