#!/bin/bash

set -xe

lsb_dist="$(. /etc/lsb-release && echo "$DISTRIB_ID")"
lsb_release="$(. /etc/lsb-release && echo "$DISTRIB_RELEASE")"

# When using this script to upgrade an old image, we need to clean some old files
rm -f /etc/init/nbd-root-disconnect.conf

# Use xnbd-client instead of nbd-client
mv /usr/bin/nbd-client /usr/bin/nbd-client.orig
ln -s /usr/bin/xnbd-client /usr/bin/nbd-client
# FIXME: add a dpkg-divert to be upgrade-proof

case "$lsb_dist" in
    Ubuntu)
        case "$lsb_release" in
            14.04)
                ln -s /etc/init.d/disconnectnbd /etc/rc6.d/S89disconnectnbd
                exit 0
                ;;
            14.10)
                update-rc.d disconnectnbd defaults
                exit 0
                ;;
            *)
                    echo "Unsupported $lsb_dist release ($lsb_release)" >&2
                    exit 1
                ;;
        esac
        ;;
    *)
        echo "Unsupported distribution $lsb_dist ($lsb_release)" >&2
        exit 1
        ;;
esac