#! /bin/bash

set -e
set -u

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
OUTPUT=$("$SCRIPTDIR/start-tunnel.sh") || exit $?
HOSTNAME=$(echo "$OUTPUT" | awk '/INSTANCE/ { print $4 }') || exit $?
echo "Host name: $HOSTNAME"
echo
"$SCRIPTDIR/open-tunnel.sh" "$HOSTNAME" "$@"
