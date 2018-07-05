# Introduction
This vagrant development setup for os2display is built with ansible.

This vagrant provides the setup for a local version of the os2display server setup.

 * Runs Ubuntu.
 * It installs nginx, php, mysql, symfony, nodejs, redis, etc.
 * It installs a database "os2display" for the symfony backend.
 * Creates the user admin:admin for the backend.
 * Afterwards it starts up the search and middleware nodejs apps.

# Vagrant setup
To enable one vagrant to have more than one alias (domain) you need to install the plugin below.

<pre>
vagrant plugin install vagrant-hostsupdater
</pre>

# Installation
You should use the install.sh script to create the htdocs folder which clones
the repositories from http://github.com/os2display.

__NOTE__: It's important that you have clone the repositories into the htdocs
folder before trying to boot the vagrant, as it uses configuration files
located in the repositories during setup.

<pre>
install.sh
</pre>

Start the vagrant.
<pre>
vagrant up
</pre>

Run `scripts/site_setup.sh` script inde fra vagranten:

<pre>
vagrant ssh
/vagrant/scripts/site_setup.sh
</pre>

Activate the search indexes:

<pre>
/vagrant/scripts/search_activate.sh
</pre>

Initialize the search indexes:

<pre>
/vagrant/scripts/search_initialize.sh
</pre>

Initialize the shared search indexes:

<pre>
/vagrant/scripts/shared_search_initialize.sh
</pre>

## Fake certificate errors in browser
Since we use self-signed certificated in this vagrant setup, you will need to accept the certificates in the browser, by visiting:

* screen.os2display.vm
* admin.os2display.vm
* search.os2display.vm
* middleware.os2display.vm

And accepting the certificates.

## Development version
If you want to run in development mode, do the following:

Modify `scripts/dev_setup.sh` to clone your forks of the bundles, instead of the
main bundles. All changes should be made on forks, and sent back to os2display
as pull requests.

Run the following scripts.

<pre>
./scripts/dev_setup.sh
./scripts/dev_config.sh
</pre>

This last script will result in the following error, if run outside the vagrant:
<pre>
Script Sensio\Bundle\DistributionBundle\Composer\ScriptHandler::clearCache
handling the post-update-cmd event terminated with an exception
</pre>

`This error can be ignored.`

Make sure to run the same php version outside as inside the vagrant.

The first script gets the bundles to the `packages/` folder. The second script
creates a copy of composer.json from the `admin` project and replaces the paths
with symlinks to the bundles in `packages/`. This results in the 
`composer-dev.json` and `composer-dev.lock` files. This should be ignored by
git, and not committed to the repository.

Afterwards, make sure assets are correctly installed. If not:
<pre>
vagrant ssh
cd /vagrant/htdocs/admin
app/console assets:install --symlink --relative
</pre>

# Troubleshooting

## Search - no mappings
If you get the following error in the admin:
<pre>
Search error.
Cause: No Living connections
</pre>

Make sure elasticsearch is running.
<pre>
ps -ef | grep elasticsearch
</pre>

Make sure the /var/run/elasticsearch directory is created with the correct permissions:
<pre>
sudo mkdir -p /var/run/elasticsearch
sudo chown elasticsearch /var/run/elasticsearch
</pre>

Start it with:
<pre>
sudo service elasticsearch start
sudo service supervisor restart
</pre>

Or use the script `scripts/fix_elasticsearch.sh` from inside the vagrant.

## Setup search
If the indexes are not activated by the `scripts/search_activate.sh` script, do the following:

When the vagrant is done bootstrapping the VM you need to activate the search index by logging into http://search.os2display.vm and click the _indexes_ tab.
Then click the _activate_ links foreach index.

## Search errors in admin
If the indexes are not initialized by the `scripts/search_initialize.sh` script, do the following:

Until content has been saved in the admin, the given search index will not have been created. This will result in "SearchPhaseExecutionException" error.
Create one of each type of content (channel,slide,screen,media) to fix this error.

# MySQL access
If you need to access the database from outside the VM with e.g. _Sequel Pro_ or any other SQL client that can connect via SSH the following can be used.
<pre>
Name: os2display
MySQL Host: 127.0.0.1
Username: root
Password: 
SSH Host: admin.os2display.vm
SSH User: vagrant
SSH Key: ~/.vagrant.d/insecure_private_key
</pre>

# Logs
* The middleware and search node have logs in their logs folders _/vagrant/htdocs/search_node/logs_ and _/vagrant/htdocs/middleware/logs_
* Nginx have logs in _/var/log/nginx_
* Supervisor logs in _/var/log/supervisor_
