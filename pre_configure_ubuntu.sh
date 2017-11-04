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

# start it up
sudo /opt/userify-server/userify-start 2>&1 |sudo tee /var/log/userify-server-initial.log &
