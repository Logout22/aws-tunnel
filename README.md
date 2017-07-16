# Installation instructions

Preparation on AWS side:
1. Create a key pair named "Tunnel" and store Tunnel.pem here (or whereever you want to execute the script).
2. Adapt the default security group to allow inbound SSH traffic from all IPs.

1. Set up AWS CLI Tools: `pip2 install --upgrade --user awscli`
2. Run `aws configure --profile <yourprofile>`, selecting your desired region.
3. Change permissions on Tunnel.pem to be more restrictive (or SSH will fail to connect): `chmod 400 Tunnel.pem`

# Usage

Use `tunnel.sh <yourprofile> [socks port]` to start redirection.
The created instance will be terminated automatically when SSH quits.
