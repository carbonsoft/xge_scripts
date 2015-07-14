#!/bin/bash

check() {
	check_netstat 0.0.0.0:1701
}

error() {
	log "Не запущен l2tp-сервер"
}

fix() {
	/etc/init.d/accel-pppd restart
}

. /usr/local/lib/angel main
