FROM bitnami/magento:2.3.4-debian-10-r12

USER root

RUN apt update
RUN apt install wget -y
RUN apt install rsync -y
RUN apt install vim -y

ENV COMPOSER_MEMORY_LIMIT -1

# This is the home directory of Magento.
WORKDIR /opt/bitnami/magento/htdocs

ADD auth.json .

RUN chown bitnami:daemon auth.json || exit 1

USER bitnami:daemon

RUN composer require mageplaza/module-core
RUN composer require mageplaza/module-smtp
RUN composer require mageplaza/module-gdpr
RUN composer require mageplaza/magento-2-social-login

# From there I removed 3 lines of code fetching the theme and extracting it to app/ and pub/ directories.

RUN chown -R bitnami:daemon app
RUN chown -R bitnami:daemon pub

RUN find /opt/bitnami/magento/htdocs -type d -print0 | xargs -0 chmod 775 && find /opt/bitnami/magento/htdocs -type f -print0 | xargs -0 chmod 664 && chown -R bitnami:daemon /opt/bitnami/magento/htdocs

USER root

COPY nami.json /root/.nami/components/com.bitnami.magento/nami.json
COPY registry.json /root/.nami/registry.json
COPY volume-init.sh /volume-init.sh
COPY run.sh /run.sh

# This is a hack against the problem described in
# [https://magento.stackexchange.com/questions/296044/invalid-parameter-given-a-valid-fileidtmp-name-is-expected].
# Changing the file-upload-temporary directory will not fix that.
# RUN sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /opt/bitnami/magento/htdocs/var/tmp|g" /opt/bitnami/php/etc/php.ini
# Somewhere Magento checks the validity of the upload directory, outside of the below file.
# Anyway, patching it works nicely. It may be a security issue, but we are running in a Docker container anyway.
RUN sed -i "s|\$isValid = false;|return;|g" /opt/bitnami/magento/htdocs/vendor/magento/framework/File/Uploader.php