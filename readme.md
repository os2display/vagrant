# Introduction
This vagrant provides the setup for a local version of the indholdskanalen server setup.
It installs nginx, php, mysql, symfony, nodejs, redis, etc.
It installs a database "indholdskanalen" for the symfony backend.
Afterwards it starts up the search and middleware nodejs apps.

# Vagrant setup
<pre>
$ vagrant plugin install vagrant-hostsupdater
</pre>

# Make htdocs and sync repositories
<pre>
$ mkdir htdocs
$ cd htdocs
$ git clone git@github.com:Indholdskanalen/indholdskanalen.git backend
$ git clone git@github.com:Indholdskanalen/search_node.git search_node
$ git clone git@github.com:Indholdskanalen/client client
</pre>
This can also be done with the setup_htdocs.sh script. This script creates the htdocs folder and pulls the repositories from git.

#How to start / restart middleware and search
<pre>
$ sudo service search_node start/restart/stop
$ sudo service middleware start/restart/stop
</pre>
The log files for each nodejs app is located in their root directories.

#If you need to start the search node manually, do the following:
<pre>
$ vagrant ssh
$ cd /vagrant/htdocs/search_node/
$ npm install
$ cp example.config.json config.json
$ ./app.js
</pre>

# To access database in Sequel pro:
<pre>
Name: vagrant indholdskanalen
MySQL Host: 127.0.0.1
Username: root
Password: vagrant
SSH Host: indholdskanalen.vm
SSH User: vagrant
SSH Key: ~/.vagrant.d/insecure_private_key
</pre>
