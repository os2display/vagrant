#!/bin/bash

cd /vagrant/htdocs/search_node && ./install.sh
cd /vagrant/htdocs/middlware && ./install.sh

echo "create database os2display" | mysql -uroot -pvagrant

cd /vagrant/htdocs/admin/ && composer install
cd /vagrant/htdocs/admin/ && app/console doctrine:migrations:migrate --no-interaction

cp /vagrant/htdocs/search_node/example.config.json /vagrant/htdocs/search_node/config.json

echo "Adding crontab"
crontab -l > mycron
echo "*/1 * * * * /usr/bin/php /vagrant/htdocs/admin/app/console os2display:core:cron" >> mycron
crontab mycron
rm mycron

# Fix /etc/hosts
echo "Add *.os2display.vm to hosts"
echo "127.0.1.1 screen.os2display.vm" >> /etc/hosts
echo "127.0.1.1 admin.os2display.vm" >> /etc/hosts
echo "127.0.1.1 search.os2display.vm" >> /etc/hosts
echo "127.0.1.1 middleware.os2display.vm" >> /etc/hosts

# Add symlink.
ln -s /vagrant/htdocs/ /home/vagrant