#! /bin/bash

set -e
set -u

. credentials.sh
ec2-start-instances --region eu-west-1 "$INSTANCEID" > /dev/null
ec2-describe-instances --region eu-west-1 "$INSTANCEID"
