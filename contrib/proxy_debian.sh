#!/bin/bash
#
# configure a proxy when PROXY is defined on the system
# via --env PROXY or export setting.
#
# relies on environment option PROXY being configured
echo "setting up proxy"
[ -f /opt/contrib/build_env.sh ] && . /opt/contrib/build_env.sh;
if [ ! -z "$PROXY" ] &&  [ ! "$PROXY" = '"nil"' ]; then
    export http_proxy=$PROXY
    export https_proxy=$http_proxy
    export HTTP_PROXY=$http_proxy
    export HTTPS_PROXY=$http_proxy
    export ftp_proxy=$(echo $http_proxy | sed 's/^http/ftp/g')
    export socks_proxy=$(echo $http_proxy | sed 's/^http/socks/g')
    export no_proxy=localhost,127.0.0.1,10.0.0.0/16,169.254.169.254
    if [ "$(id -u)" = "0" ] ; then # should only be done by root
    # clear out previous setting
    [ -f /etc/apt/apt.conf ] && cat /etc/apt/apt.conf | grep -v '::proxy' > /etc/apt/apt.conf
    # reset the apt.conf
      cat >> /etc/apt/apt.conf <<APT_CONF
Acquire::http::proxy "${http_proxy}";
Acquire::https::proxy "${http_proxy}";
Acquire::ftp::proxy "${ftp_proxy}";
Acquire::socks::proxy "${socks_proxy}";
APT_CONF
fi

else
    unset PROXY
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset ftp_proxy
    unset socks_proxy
    unset no_proxy
    [ -f /etc/apt/apt.conf ] && cat /etc/apt/apt.conf | grep -v '::proxy' > /etc/apt.conf
    echo "skiping proxy settings"
    echo "If proxy settings are needed, use command before running docker: "
    echo "for build,  echo "PROXY='http://myproxy:8080'" >contrib/build_env.sh "
    echo " or "
    echo "for run, docker run --env PROXY='http://myproxy:8080' ..."
fi
