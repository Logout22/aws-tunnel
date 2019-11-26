A script to open a SOCKS proxy via an SSH connection to an AWS EC2 instance

# Installation

For this script to work, several things need to be set up in advance.

## Preparation on AWS side

1. Open the AWS console
2. In IAM, create a key pair named "Tunnel" and store Tunnel.pem here (or whereever you want to execute the script).
3. In EC2, adapt the default security group to allow inbound SSH traffic from all IPs.

## Preparation on user side

1. Set up AWS CLI Tools: `pip install --upgrade --user awscli`
2. Run `aws configure --profile <yourprofile>`, entering details for your desired region(s).
3. Change permissions on Tunnel.pem to be more restrictive (or SSH will fail to connect): `chmod 400 Tunnel.pem`

# Usage

Use `tunnel.sh <yourprofile> [socks port]` to start redirection.
The created instance will be terminated automatically when SSH quits.
