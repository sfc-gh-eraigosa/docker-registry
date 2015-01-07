#!/bin/bash
#
# configure export PIP_OPTIONS
# - setup --proxy option for pip
#
[ -f /opt/contrib/build_env.sh ] && . /opt/contrib/build_env.sh
if [ ! -z "$PROXY" ] &&  [ ! "$PROXY" = '"nil"' ]; then
    export PIP_OPTIONS="--proxy $PROXY"
else
    export PIP_OPTIONS=""
fi
