#! /bin/bash

# /usr/local/sbin/checkshutdown.sh

set -e
set -u

logit()
{
    logger -p local0.notice -s -- AutoShutdown: "$@"
}

IsBusy()
{
    USERCOUNT=$(who | wc -l);
    if [[ $USERCOUNT -gt 0 ]]; then
        logit some users still connected, auto shutdown cancelled
        return 0
    fi
    return 1
}

OFFFILE="/var/spool/shutdown_off"

# turns off the auto shutdown
if [ -e $OFFFILE ]; then
    logit auto shutdown is turned off by existents of $OFFFILE
    exit 0
fi

if ! IsBusy; then
    logit auto shutdown caused by cron
    /sbin/halt -p
fi
