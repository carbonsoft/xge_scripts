#!/bin/bash

check() {
        . /cfg/config
	check_netstat "${httpd['internal_ip']}:80"
}

error() {
	log "Не слушает внутренний http-сервер XGE"
}

. /usr/local/lib/angel main_critical
