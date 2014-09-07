#!/bin/bash

if grep 169.1.37.99 /app/xge/cfg/config; then
	mv -f /app/xge/cfg/config /app/xge/mnt/backup
	mv -f /app/xge/skelet/cfg/config /app/xge/cfg/config
fi
