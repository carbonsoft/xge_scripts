#!/bin/bash

PACKET_TYPE="$1"
shift

PARAMS="$@"
PARAMS=${PARAMS//Framed-IP-Address/$FRAMED_IP_ADDRESS}
n=$'\n'
LOGFILE="/var/log/xge/sessions.log"
[ ! -d /var/log/xge/ ] && mkdir -p /var/log/xge/
echo "$0[$$]: $PACKET_TYPE $PARAMS" >> $LOGFILE

if [ "$PACKET_TYPE" = 'Disconnect-Request' ]; then
	PARAMS="session disconnect $FRAMED_IP_ADDRESS"
fi

REPLY="$( . /usr/local/bin/xgesh $PARAMS 2>&1 )"
ERR=$?
REPLY="${REPLY//$n/ }"
REPLY="${REPLY//  / }"
REPLY="${REPLY//\"/}"
# echo -e "Reply-Message = \"$REPLY (ERR: $ERR)\""
# REPLY="${REPLY//[^a-zA-Z0-9_. ]/ }"
echo -e "Reply-Message = \"${REPLY:0:1010} (ERR: $ERR)\""
echo "$0[$$]: $@ REPLY: $REPLY (ERR: $ERR)" >> $LOGFILE
exit 0
