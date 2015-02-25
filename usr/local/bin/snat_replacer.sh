#!/bin/bash

. /usr/local/lib/carbon_channels_lib

main() {
	if [ "${reservation:-0}" != "1" ]; then
		__log reservation is off - skip
		return 0
	fi

	__log start snat_replacer
	for channel in $channels_list; do
		__log check_and_fix_channel $channel
		check_and_fix_channel $channel
	done
}

main "$@"