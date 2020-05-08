#!/bin/bash

if [ -d "/magento/app" ]; then
    echo "Volume directory [/magento] is not empty. Doing nothing."
else
    echo "Volume directory [/magento] is empty. Pre-populating it."
    mkdir /magento/app
    cp -R /opt/bitnami/magento/htdocs/app/etc /magento/app/etc
    mkdir /magento/pub
    cp -R /opt/bitnami/magento/htdocs/pub/media /magento/pub/media

    chown -R bitnami:daemon /magento
    find /magento -type d -print0 | xargs -0 chmod 775 && find /magento -type f -print0 | xargs -0 chmod 664 && chown -R bitnami:daemon /magento
fi