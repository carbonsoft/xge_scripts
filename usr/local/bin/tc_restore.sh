#!/bin/bash

[ -n "$1" ] && exec < $1

exec tc -b -
