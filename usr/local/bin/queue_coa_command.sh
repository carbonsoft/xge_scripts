#!/bin/bash

echo "$@" >> /var/spool/xge/cmd/$(date +%s)_$$.coa
