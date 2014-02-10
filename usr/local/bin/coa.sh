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

REPLY="$( . /usr/local/bin/xgesh $PARAMS 2>&1)"
ERR=$?
REPLY="${REPLY//\"/}"

while read line; do
    echo "Reply-Message += \"$line\","
done <<< "$REPLY"
echo "Error-Cause = $((200+ERR))"
echo "$0[$$]: $@ REPLY: $REPLY (ERR: $ERR)" >> $LOGFILE
exit $ERR
# todo
#  < 0 : fail      the module failed
#  = 0 : okthe module succeeded
#  = 1 : reject    the module rejected the user
#  = 2 : fail      the module failed
#  = 3 : okthe module succeeded
#  = 4 : handled   the module has done everything to handle the request
#  = 5 : invalid   the user's configuration entry was invalid
#  = 6 : userlock  the user was locked out
#  = 7 : notfound  the user was not found
#  = 8 : noop      the module did nothing
#  = 9 : updated   the module updated information in the request
#  > 9 : fail      the module failed
