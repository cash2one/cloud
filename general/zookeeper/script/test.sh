#!/bin/sh

ZK_SCRIPT_INSERT_LINE="2,3"
ZK_SCRIPT_NAME="123.txt"

ZOOCFG="zoo.cfg"
GREP="grep"

INSERT_STR='ZOO_LOG_DIR="$($GREP "^[[:space:]]*dataLogDir" "$ZOOCFG" | sed -e \'s/.*=//\')"'

echo "$ZK_SCRIPT_INSERT_LINE i/$INSERT_STR"
sed '$ZK_SCRIPT_INSERT_LINE i/$INSERT_STR' $ZK_SCRIPT_NAME
