#!/bin/bash

check() {
	. /cfg/config
	ping -qc 1 -w 1 "${radclient['coa_client.ip']%%:*}" &>/dev/null
}

error() {
	log "Radius-клиент (биллинг) ${radclient['coa_client.ip']%%:*} недоступен"
}

. /usr/local/lib/angel main
