#!/bin/bash

check() {
	. /cfg/config
	ping -qc 1 -w 1 "${radclient['acctserver']%%:*}" &>/dev/null
}

error() {
	log "Сервер аккаунтинга ${radclient['acctserver']%%:*} недоступен"
}

. /usr/local/lib/angel main
