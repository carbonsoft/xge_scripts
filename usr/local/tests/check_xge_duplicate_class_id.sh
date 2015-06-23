#!/bin/bash

check() {
	! xgesh session dump | cut -d ' ' -f7 | sort | uniq -d | tee -a /dev/stderr | grep -q ''
}

error() {
	log "Дублирующийся class_id у нескольких абонентов"
}

. /usr/local/lib/angel main
