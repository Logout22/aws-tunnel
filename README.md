A script to open a SOCKS proxy via an SSH connection to an AWS EC2 instance

# Installation

For this script to work, several things need to be set up in advance.

## Preparation on AWS side

1. Open the AWS console
2. In IAM, create a key pair named "Tunnel" and store Tunnel.pem here (or whereever you want to execute the script).
   I recommend setting up a dedicated user for AWS console access in IAM, with restricted permissions (see "Example policy" below).
3. In EC2, adapt the default security group to allow inbound SSH traffic from all IPs.

## Preparation on user side

1. Set up AWS CLI Tools: `pip install --upgrade --user awscli`
2. Run `aws configure --profile <yourprofile>`, entering details for your desired region(s).
3. Change permissions on Tunnel.pem to be more restrictive (or SSH will fail to connect): `chmod 400 Tunnel.pem`

# Usage

Use `tunnel.sh <yourprofile> [socks port]` to start redirection.
The created instance will be terminated automatically when SSH quits.

# Example policy

You need to grant access for creating and tearing down instances
to the user whose access key you entered in "Preparation on user side".
Add a user-managed policy, and paste something like this into the JSON editor:

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowBasicEC2ActionsForAllResources",
                "Effect": "Allow",
                "Action": [
                    "ec2:Describe*",
                    "ec2:RunInstances",
                    "ec2:TerminateInstances"
                ],
                "Resource": "*"
            }
        ]
    }

Then, assign this policy to the user.
