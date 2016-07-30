#! /bin/bash

set -e
set -u

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SCRIPTDIR/credentials.sh"
ec2-stop-instances --region eu-west-1 "$INSTANCEID"
