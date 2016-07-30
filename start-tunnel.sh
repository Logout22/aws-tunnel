#! /bin/bash
. credentials.sh
ec2-start-instances --region eu-west-1 "$INSTANCEID"
ec2-describe-instances --region eu-west-1 "$INSTANCEID"

