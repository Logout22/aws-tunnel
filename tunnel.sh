#! /bin/bash

set -e

INSTANCETYPE=t3.nano
AWSKEYNAME=Tunnel
TUNNELCERT=$AWSKEYNAME.pem

function check_prerequisites() {
    if [[ -z "$1" ]]; then
        echo Please select a configuration profile.
        exit 1
    fi
    if [[ ! -f "$TUNNELCERT" ]]; then
        echo "Please provide a certificate for logging into the new instance ($TUNNELCERT)."
        exit 1
    fi
    if [[ $(stat -c %A "$TUNNELCERT") != "-r--------" ]]; then
        echo "Permissions on certificate '$TUNNELCERT' are insecure. Please change to 400."
        exit 1
    fi
    if ! aws --version >/dev/null; then
        echo Please install the AWS CLI using
        echo pip install --upgrade --user awscli
        exit 5
    fi
    if ! python3 -c "import json"; then
        echo Please install Python 3 and the JSON module.
        exit 10
    fi
}

function retrieve_ami() {
    echo "Please enter the desired AMI for your region"
    echo "(from https://aws.amazon.com/amazon-linux-ami/#Amazon_Linux_AMI_IDs):"
    read -r AWSLINUXAMI
    if [[ -z "$AWSLINUXAMI" ]]; then
        echo "You need to enter a valid AMI. Aborting."
        exit 20
    fi
}

function launch_instance() {
    aws ec2 run-instances --profile "$PROFILE" \
        --image-id "$AWSLINUXAMI" \
        --instance-type "$INSTANCETYPE" \
        --key-name "$AWSKEYNAME" \
        --output json
}

function get_instance_id() {
    python3 -c "import sys, json; print(json.load(sys.stdin)['Instances'][0]['InstanceId'])"
}

function get_instance_description() {
    aws ec2 describe-instances --profile "$PROFILE" --instance-ids "$INSTANCEID" --output json
}

function get_instance_state() {
    python3 -c "import sys, json; print(json.load(sys.stdin)['Reservations'][0]['Instances'][0]['State']['Name'])"
}

function get_instance_host_name() {
    python3 -c "import sys, json; print(json.load(sys.stdin)['Reservations'][0]['Instances'][0]['PublicDnsName'])"
}

function wait_for_instance() {
    local STATEJSON
    local STATE
    local WAITING_INTERVAL=1
    while [[ $STATE != "running" ]]; do
        STATEJSON=$(get_instance_description || exit)
        STATE=$(echo "$STATEJSON" | get_instance_state || exit)
        INSTANCEHOSTNAME=$(echo "$STATEJSON" | get_instance_host_name || exit)
        echo Waiting for $WAITING_INTERVAL seconds...
        sleep $WAITING_INTERVAL
        WAITING_INTERVAL=$((WAITING_INTERVAL * 2))
    done
}

function open_tunnel() {
    ssh -D "$PROXYPORT" -i "$TUNNELCERT" ec2-user@"$INSTANCEHOSTNAME"
}

function terminate_instance() {
    aws ec2 terminate-instances --profile "$PROFILE" --instance-ids "$INSTANCEID" > /dev/null
}

check_prerequisites "$1"
PROFILE=$1
PROXYPORT=${2:-8080}
retrieve_ami

INSTANCEID=$(launch_instance | get_instance_id || exit)
INSTANCEHOSTNAME=
echo "Launching instance with id $INSTANCEID"
wait_for_instance "$INSTANCEID"
echo "Instance successfully launched. Opening SSH tunnel to $INSTANCEHOSTNAME."
open_tunnel
echo "Tunnel closed, shutting down image."
terminate_instance
