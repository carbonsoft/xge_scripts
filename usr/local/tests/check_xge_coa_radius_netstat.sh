#!/bin/bash

check() {
        . /cfg/config
	check_netstat "${radclient['nas_identifier']}:${radclient['coa_server.port']}"
}

error() {
	log "Не слушает coa_server"
}

fix() {
	/etc/init.d/radiusd restart	
}

. /usr/local/lib/angel main
