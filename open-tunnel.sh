#! /bin/bash

set -e
set -u

ssh -D "${2:-8080}" -i "Tunnel.pem" "ubuntu@$1"
