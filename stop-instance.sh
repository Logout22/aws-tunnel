#! /bin/bash

set -e
set -u

. credentials.sh
ec2-stop-instances --region eu-west-1 "$INSTANCEID"
