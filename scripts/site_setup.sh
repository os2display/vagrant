#!/bin/bash

cd /vagrant/htdocs/search_node && ./install.sh
cd /vagrant/htdocs/middleware && ./install.sh

echo "create database os2display" | mysql -uroot -pvagrant

cd /vagrant/htdocs/admin/ && composer install
cd /vagrant/htdocs/admin/ && bin/console doctrine:migrations:migrate --no-interaction

# Add admin user
cd /vagrant/htdocs/admin/ && bin/console fos:user:create admin admin@admin.os2display.vm admin --super-admin

cp /vagrant/htdocs/search_node/example.config.json /vagrant/htdocs/search_node/config.json

echo "Adding crontab"
crontab -l > mycron
echo "*/1 * * * * /usr/bin/php /vagrant/htdocs/admin/bin/console os2display:core:cron" >> mycron
crontab mycron
rm mycron

# Fix /etc/hosts
sudo sh -c 'echo "127.0.1.1 screen.os2display.vm" >> /etc/hosts'
sudo sh -c 'echo "127.0.1.1 admin.os2display.vm" >> /etc/hosts'
sudo sh -c 'echo "127.0.1.1 search.os2display.vm" >> /etc/hosts'
sudo sh -c 'echo "127.0.1.1 middleware.os2display.vm" >> /etc/hosts'

# Add symlink.
ln -s /vagrant/htdocs/ /home/vagrant

# Add supervisor conf
sudo cp /vagrant/templates/supervisor-job-queue.j2 /etc/supervisor/conf.d/job_queue_admin.conf
sudo cp /vagrant/templates/supervisor-middleware.j2 /etc/supervisor/conf.d/middleware.conf
sudo cp /vagrant/templates/supervisor-search_node.j2 /etc/supervisor/conf.d/search_node.conf
sudo service supervisor restart
