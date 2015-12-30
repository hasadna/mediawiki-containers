#!/bin/bash

# Basic mediawiki-containers install tests.

set -e

check_service() {
    # Make sure that the wiki is reachable & RESTBase works
    curl http://localhost/api/rest_v1/page/html/Main_Page \
        | grep -q "MediaWiki has been successfully installed"
}

# Make sure the installer does not ask questions
export MEDIAWIKI_DOMAIN=localhost
export AUTO_UPDATE=true

CHECKOUT=$(pwd)

cd /tmp

if [ -d /srv/mediawiki-containers ];then
    echo "Found existing /srv/mediawiki-containers checkout."
    read -p "Delete it? (y/[n]): " DELETE_IT
    if [ "$DELETE_IT" == 'y' ];then
        rm -rf /srv/mediawiki-containers
    fi
fi
    
git clone "$CHECKOUT" /srv/mediawiki-containers


cat "$CHECKOUT/mediawiki-containers" | bash -s install

check_service

# Restart the service
service mediawiki-containers restart

sleep 10

check_service

# Exercise the automatic updater
/etc/cron.daily/mediawiki-containers

check_service
