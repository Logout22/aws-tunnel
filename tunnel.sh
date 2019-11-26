#! /bin/bash

set -o nounset

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

function terminate_instance() {
    echo "Shutting down image."
    rm -f "$SHOULD_RUN_FILE"
    trap - INT QUIT TERM EXIT
    aws ec2 terminate-instances --profile "$PROFILE" --instance-ids "$INSTANCEID" > /dev/null
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

function retry_command() {
    local COMMAND=$1
    local RETRIES=0
    local MAX_RETRIES=7
    local WAITING_INTERVAL=1
    local RETURN_CODE=1
    while true; do
        $COMMAND
        RETURN_CODE=$?
        if [[ $RETURN_CODE -eq 0 ]]; then
            return 0
        fi
        if ! [[ -f "$SHOULD_RUN_FILE" ]]; then
            exit 30
        fi
        RETRIES=$((RETRIES + 1))
        if [[ $RETRIES -gt $MAX_RETRIES ]]; then
            exit 40
        fi
        echo Waiting for $WAITING_INTERVAL seconds...
        sleep $WAITING_INTERVAL
        WAITING_INTERVAL=$((WAITING_INTERVAL * 2))
    done
    return $RETURN_CODE
}

function get_instance() {
    local STATEJSON=
    local STATE=
    STATEJSON=$(get_instance_description) || exit
    STATE=$(echo "$STATEJSON" | get_instance_state) || exit
    INSTANCEHOSTNAME=$(echo "$STATEJSON" | get_instance_host_name) || exit
    [[ $STATE = "running" ]]
}

function open_tunnel() {
    ssh -D "$PROXYPORT" -i "$TUNNELCERT" ec2-user@"$INSTANCEHOSTNAME"
}

check_prerequisites "$1"
PROFILE=$1
PROXYPORT=${2:-8080}
retrieve_ami

INSTANCEID=$(launch_instance | get_instance_id) || exit
echo "Launching instance with id $INSTANCEID"
trap terminate_instance INT QUIT TERM EXIT
SHOULD_RUN_FILE=$(mktemp) || exit
INSTANCEHOSTNAME=
retry_command "get_instance $INSTANCEID" || exit
echo "Instance successfully launched. Opening SSH tunnel to $INSTANCEHOSTNAME."
retry_command open_tunnel || exit
echo "Tunnel closed."
