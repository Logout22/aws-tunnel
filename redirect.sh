#! /bin/bash

set -e
set -u

OUTPUT=$(./start-tunnel.sh) || exit $?
HOSTNAME=$(echo "$OUTPUT" | awk '/INSTANCE/ { print $4 }') || exit $?
echo "Host name: $HOSTNAME"
echo
./open-tunnel.sh "$HOSTNAME" "$@"
