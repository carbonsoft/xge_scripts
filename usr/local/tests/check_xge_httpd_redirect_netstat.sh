#!/bin/bash

check() {
        . /cfg/config
	check_netstat "${httpd['internal_ip']}:440"
}

error() {
	log "Не слушает http-сервер XGE для неавторизованных"
}

. /usr/local/lib/angel main_critical
