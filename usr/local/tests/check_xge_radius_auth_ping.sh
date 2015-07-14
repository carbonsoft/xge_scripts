#!/bin/bash

check() {
	. /cfg/config
	ping -qc 1 -w 1 "${radclient['authserver']%%:*}" &>/dev/null
}

error() {
	log "Сервер авторизации ${radclient['authserver']%%:*} недоступен"
}

. /usr/local/lib/angel main
