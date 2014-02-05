#!/bin/bash

n=$'\n'
LOGFILE="/var/log/coa/coa.log"
[ -d /var/log/coa/ ] || mkdir -p /var/log/coa/
echo "$0[$$]: $@" >> $LOGFILE
REPLY="$( . /usr/local/bin/xgesh $@ 2>&1 )"
ERR=$?
REPLY="${REPLY//$n/ }"
REPLY="${REPLY//  / }"
echo -e "Reply-Message = \"$REPLY (ERR: $ERR)\""
echo "$0[$$]: $@ REPLY: $REPLY (ERR: $ERR)" >> $LOGFILE
exit 0
