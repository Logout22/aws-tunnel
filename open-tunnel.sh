#! /bin/bash

set -e
set -u

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ssh -D "${2:-8080}" -i "$SCRIPTDIR/Tunnel.pem" "ubuntu@$1"
