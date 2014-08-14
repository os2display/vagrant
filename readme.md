# Vagrant setup
<pre>
$ vagrant plugin install vagrant-hostsupdater
</pre>

# Make htdocs and sync repositories
<pre>
$ mkdir htdocs
$ cd htdocs
$ git clone git@github.com:Indholdskanalen/indholdskanalen.git backend_indholdskanalen
$ git clone git@github.com:Indholdskanalen/search_node.git search_node
</pre>
This can also be done with the setup_htdocs.sh script. This script creates the htdocs folder and pulls the repositories from git.

# To get the system up and running
You need to start the search node. Do the following:
<pre>
$ vagrant ssh
$ cd /vagrant/htdocs/search_node/
$ npm install
$ cp example.config.json config.json
$ ./app.js
</pre>

# To setup cron
<pre>
$ vagrant ssh
$ crontab -e
</pre>
Add (for cron every hour (5 minutes past)) to the end:
<pre>
5 * * * * /usr/bin/php /var/www/backend_indholdskanalen/app/console infostander:schedule
</pre>

# To access database in Sequal pro:
<pre>
Name: vagrant infostander
MySQL Host: 127.0.0.1
Username: root
Password: vagrant
SSH Host: inholdskanalen.vm
SSH User: vagrant
SSH Key: ~/.vagrant.d/insecure_private_key
</pre>
