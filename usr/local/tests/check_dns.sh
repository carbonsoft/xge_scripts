#!/bin/bash

check() {
	check_dns
}

error() {
	log "Не настроены DNS"	
}

. /usr/local/lib/angel main_critical
