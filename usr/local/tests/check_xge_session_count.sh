#!/bin/bash

check() {
	count="$(/usr/local/bin/xgesh session list | grep -cv '^$')"
}

error() {
	[ "$count" != '0' -a "$count" -lt "1000000" ]
}

. /usr/local/lib/angel main
