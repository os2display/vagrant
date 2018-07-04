#!/bin/bash

cd /vagrant/htdocs/search_node && ./install.sh
cd /vagrant/htdocs/middleware && ./install.sh

# Make sure middleware/logs is created
mkdir /vagrant/htdocs/middleware/logs

echo "create database os2display" | mysql -uroot

cd /vagrant/htdocs/admin/ && composer install
cd /vagrant/htdocs/admin/ && bin/console doctrine:migrations:migrate --no-interaction

# Add admin user
cd /vagrant/htdocs/admin/ && bin/console fos:user:create admin admin@admin.os2display.vm admin --super-admin

# Import templates
cd /vagrant/htdocs/admin/ && bin/console os2display:core:templates:load

# Enable all temp
cd /vagrant/htdocs/admin/ && bin/console doctrine:query:sql "UPDATE ik_screen_templates SET enabled=1;"
cd /vagrant/htdocs/admin/ && bin/console doctrine:query:sql "UPDATE ik_slide_templates SET enabled=1;"

cp /vagrant/htdocs/search_node/example.config.json /vagrant/htdocs/search_node/config.json

echo "Adding crontab"
crontab -l > mycron
echo "*/1 * * * * /usr/bin/php /vagrant/htdocs/admin/bin/console os2display:core:cron" >> mycron
crontab mycron
rm mycron

# Add symlink.
ln -s /vagrant/htdocs/ /home/vagrant

# Add supervisor conf
sudo cp /vagrant/templates/supervisor-job-queue.j2 /etc/supervisor/conf.d/job_queue_admin.conf
sudo cp /vagrant/templates/supervisor-middleware.j2 /etc/supervisor/conf.d/middleware.conf
sudo cp /vagrant/templates/supervisor-search_node.j2 /etc/supervisor/conf.d/search_node.conf
sudo service supervisor restart

# Change nginx user and group to vagrant to avoid permission issues.
sudo sed -i 's/user = www-data/user = vagrant/g' /etc/php/7.2/fpm/pool.d/www.conf
sudo sed -i 's/group = www-data/group = vagrant/g' /etc/php/7.2/fpm/pool.d/www.conf
sudo service php7.2-fpm restart
