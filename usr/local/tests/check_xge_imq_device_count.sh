#!/bin/bash

check() {
	[ "$(ip l | grep imq | wc -l)" = '2' ]
}

error() {
	log "Неправильное количество IMQ-девайсов"
}

. /usr/local/lib/angel main_critical
