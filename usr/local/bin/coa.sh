#!/bin/bash

PARAMS="$@"
PARAMS=${PARAMS//Framed-IP-Address/$FRAMED_IP_ADDRESS}
n=$'\n'
LOGFILE="/var/log/xge/coa.log"
[ ! -d /var/log/xge/ ] && mkdir -p /var/log/xge/
echo "$0[$$]: $PARAMS" >> $LOGFILE
REPLY="$( . /usr/local/bin/xgesh $PARAMS 2>&1 )"
ERR=$?
REPLY="${REPLY//$n/ }"
REPLY="${REPLY//  / }"
REPLY="${REPLY//\"/}"
echo -e "Reply-Message = \"$REPLY (ERR: $ERR)\""
echo "$0[$$]: $@ REPLY: $REPLY (ERR: $ERR)" >> $LOGFILE
exit 0
