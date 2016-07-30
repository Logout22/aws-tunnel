#! /bin/bash

set -e
set -u

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "$SCRIPTDIR/credentials.sh"
ec2-start-instances --region eu-west-1 "$INSTANCEID" > /dev/null
ec2-describe-instances --region eu-west-1 "$INSTANCEID"
