#! /bin/bash

set -e
set -u

SCRIPTDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=credentials.sh
. "$SCRIPTDIR/credentials.sh"
ec2-start-instances --region "$REGION" "$INSTANCEID" > /dev/null
ec2-describe-instances --region "$REGION" "$INSTANCEID"
