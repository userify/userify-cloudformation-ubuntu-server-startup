#! /bin/bash -e

# This script is designed to be run automatically as root
# (not standalone) on Ubuntu 16.04 LTS.

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
set +e
# this might get skipped
sudo DEBIAN_FRONTEND=noninteractive apt-get \
    -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    -qqy upgrade
set -e
sudo DEBIAN_FRONTEND=noninteractive apt-get \
    -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    -qqy install build-essential python-dev libffi-dev zlib1g-dev \
        libjpeg-dev libssl-dev python-lxml libxml2-dev libldap2-dev \
        libsasl2-dev libxslt1-dev ntpdate curl libhiredis-dev sudo \
		python-virtualenv jq redis-tools awscli

# get immediate timefix
set +e
sudo ntpdate pool.ntp.org
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    install -qqy ntp
set -e

if [ ! -f /etc/init.d/userify-server ]; then

    # create the userify-server init script
cat << "EOF" >/etc/init.d/userify-server
#!/bin/bash
# /etc/rc.d/init.d/userify-server
# Userify Server startup script
# This script is designed for maximum compatibility across all distributions,
# including those that are running systemd and sysv

### BEGIN INIT INFO
# Provides:          userify-server
# Required-Start:    $network $syslog
# Required-Stop:     $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start userify-server at boot time
# Description:       Starts the Userify Server https://userify.com from /opt/userify-server.
### END INIT INFO

# chkconfig: 2345 20 80
# description: Userify Server startup script

case "$1" in
    start)
        # removed stop
        echo -n "Starting Userify Server: "
        /opt/userify-server/userify-start &
        ;;
    stop)
        echo -n "Shutting down Userify Server: "
        pkill userify-start
        pkill userify-server
        ;;
    status)
        pgrep userify-server
        ;;
    restart)
        $0 stop; $0 start
        ;;
    reload)
        $0 stop; $0 start
        ;;
    *)
        echo "Usage: userify-server {start|stop|status|reload|restart}"
        exit 1
        ;;
esac
EOF
    chmod +x /etc/init.d/userify-server
    set +e
    [ -f /usr/sbin/update-rc.d ] && sudo update-rc.d userify-server defaults
    # $(command -v systemctl) && sudo systemctl enable userify-server
    set -e
fi

# start it up
sudo /opt/userify-server/userify-start 2>&1 |sudo tee /var/log/userify-server-initial.log &
