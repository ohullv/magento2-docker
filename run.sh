/usr/sbin/cron

echo "Running compile on Magento."
sudo -u bitnami php -d memory_limit=4096M /opt/bitnami/magento/htdocs/bin/magento setup:di:compile -vvv || true

echo "Running deployment on Magento sources."
sudo -u bitnami php -d memory_limit=4096M /opt/bitnami/magento/htdocs/bin/magento setup:static-content:deploy -f -vvv || true

echo "Starting Apache..."