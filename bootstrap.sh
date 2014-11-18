#!/usr/bin/env bash

# APT
echo "Updating APT"
apt-get update > /dev/null 2>&1

# Set timezone.
echo "Setting up timezone..."
echo "Europe/Copenhagen" > /etc/timezone
/usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1

# Set locale
echo "Setting up locale..."
echo en_GB.UTF-8 UTF-8 > /etc/locale.gen
echo en_DK.UTF-8 UTF-8 >> /etc/locale.gen
echo da_DK.UTF-8 UTF-8 >> /etc/locale.gen
/usr/sbin/locale-gen > /dev/null 2>&1
export LANGUAGE=en_DK.UTF-8 > /dev/null 2>&1
export LC_ALL=en_DK.UTF-8 > /dev/null 2>&1
/usr/sbin/dpkg-reconfigure --frontend noninteractive locales > /dev/null 2>&1

# Add dotdeb
cat > /etc/apt/sources.list.d/dotdeb.list <<DELIM
deb http://packages.dotdeb.org wheezy all
deb-src http://packages.dotdeb.org wheezy all
DELIM
wget http://www.dotdeb.org/dotdeb.gpg > /dev/null 2>&1
apt-key add dotdeb.gpg  > /dev/null 2>&1
rm dotdeb.gpg
apt-get update > /dev/null 2>&1

# Mysql
echo "Configuring mysql"
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password vagrant' > /dev/null 2>&1
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password vagrant' > /dev/null 2>&1

apt-get install -y mysql-server > /dev/null 2>&1

# PHP5
echo "Installing php"
apt-get install -y php5-fpm php5-cli php5-xdebug php5-mysql php5-curl php5-gd git > /dev/null 2>&1

sed -i '/;date.timezone =/c date.timezone = Europe/Copenhagen' /etc/php5/cli/php.ini
sed -i '/;date.timezone =/c date.timezone = Europe/Copenhagen' /etc/php5/fpm/php.ini

sed -i '/upload_max_filesize = 2M/cupload_max_filesize = 256M' /etc/php5/fpm/php.ini
sed -i '/post_max_size = 8M/cpost_max_size = 300M' /etc/php5/fpm/php.ini

sed -i '/;listen.owner = www-data/c listen.owner = vagrant' /etc/php5/fpm/pool.d/www.conf
sed -i '/;listen.group = www-data/c listen.group = vagrant' /etc/php5/fpm/pool.d/www.conf
sed -i '/;listen.mode = 0660/c listen.mode = 0660' /etc/php5/fpm/pool.d/www.conf

# Set php memory limit to 256mb
sed -i '/memory_limit = 128M/c memory_limit = 256M' /etc/php5/fpm/php.ini

# Redis
echo "Installing redis"
apt-get install -y redis-server > /dev/null 2>&1

# Memcache
echo "Installing memcache"
apt-get install -y memcached php5-memcached > /dev/null 2>&1

# APC
echo "Configuring APC"
apt-get install -y php-apc > /dev/null 2>&1

cat > /etc/php5/conf.d/apc.ini <<DELIM
apc.enabled=1
apc.shm_segments=1
apc.optimization=0
apc.shm_size=64M
apc.ttl=7200
apc.user_ttl=7200
apc.num_files_hint=1024
apc.mmap_file_mask=/tmp/apc.XXXXXX
apc.enable_cli=1
apc.cache_by_default=1
DELIM

# x-debug
echo "Configure x-debug"

cat << DELIM >> /etc/php5/conf.d/20-xdebug.ini
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
xdebug.remote_host=192.168.50.1
xdebug.remote_port=9000
xdebug.remote_autostart=0
DELIM

# Nginx
echo "Installing nginx"
apt-get install -y nginx > /dev/null 2>&1
unlink /etc/nginx/sites-enabled/default

# Setup web root
ln -s /vagrant/htdocs /var/www

# Config files into nginx
cat > /etc/nginx/sites-available/service.indholdskanalen.vm.conf <<DELIM
upstream nodejs_search {
  server 127.0.0.1:3010;
}

server {
  listen 80;

  server_name service.indholdskanalen.vm;
  root /var/www/backend/web;

  rewrite ^ https://\$server_name\$request_uri? permanent;

  access_log /var/log/nginx/backend_access.log;
  error_log /var/log/nginx/backend_error.log;
}


# HTTPS server
#
server {
  listen 443;

  server_name service.indholdskanalen.vm;
  root /var/www/backend/web;

  client_max_body_size 300m;

  access_log /var/log/nginx/backend_access.log;
  error_log /var/log/nginx/backend_error.log;

  location / {
    # try to serve file directly, fallback to rewrite
    try_files \$uri @rewriteapp;
  }

  location @rewriteapp {
    # rewrite all to app.php
    rewrite ^(.*)\$ /app_dev.php/\$1 last;
  }

  location ~ ^/(app|app_dev|config)\.php(/|\$) {
    fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_split_path_info ^(.+\.php)(/.*)\$;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    fastcgi_param HTTPS off;
  }

  # deny access to .htaccess files, if Apache's document root
  # concurs with nginx's one
  location ~ /\.ht {
    deny all;
  }

  location /ik-templates/ {
    add_header 'Access-Control-Allow-Origin' "*";
  }

  location /proxy/ {
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;

    proxy_buffering off;

    proxy_pass http://nodejs_search/;
    proxy_redirect off;
  }

  location /socket.io/ {
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_pass http://nodejs_search;
  }

  ssl on;
  ssl_certificate /etc/ssl/nginx/server.cert;
  ssl_certificate_key /etc/ssl/nginx/server.key;

  ssl_session_timeout 5m;

  ssl_protocols SSLv3 TLSv1;
  ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
  ssl_prefer_server_ciphers on;
}
DELIM

cat > /etc/nginx/sites-available/indholdskanalen.vm.conf <<DELIM
upstream nodejs_middleware {
  server 127.0.0.1:3020;
}

server {
  listen 80;

  server_name indholdskanalen.vm;
  root /var/www/client;

  rewrite ^ https://\$server_name\$request_uri? permanent;

  access_log /var/log/nginx/client_access.log;
  error_log /var/log/nginx/client_error.log;
}


# HTTPS server
#
server {
  listen 443;

  server_name indholdskanalen.vm;
  root /var/www/client;

  client_max_body_size 300m;

  access_log /var/log/nginx/client_access.log;
  error_log /var/log/nginx/client_error.log;

  location / {
    try_files \$uri \$uri/ /index.html;
  }

  location /proxy/ {
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;

    proxy_buffering off;

    proxy_pass http://nodejs_middleware/;
    proxy_redirect off;
  }

  location /socket.io/ {
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_pass http://nodejs_middleware;
  }

  ssl on;
  ssl_certificate /etc/ssl/nginx/server.cert;
  ssl_certificate_key /etc/ssl/nginx/server.key;

  ssl_session_timeout 5m;

  ssl_protocols SSLv3 TLSv1;
  ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
  ssl_prefer_server_ciphers on;
}
DELIM

# Symlink
ln -s /etc/nginx/sites-available/service.indholdskanalen.vm.conf /etc/nginx/sites-enabled/service.indholdskanalen.vm.conf
ln -s /etc/nginx/sites-available/indholdskanalen.vm.conf /etc/nginx/sites-enabled/indholdskanalen.vm.conf

# SSL
mkdir /etc/ssl/nginx
cat > /etc/ssl/nginx/server.key <<DELIM
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAr/XEHIjUq9JiI2ciKjJ6a/bdf5/3FxrJXIYiw+rFO7GEy+ly
RfALVhMiZpZQOo4fYk0AvTb3ZtTmwRDvP3uIsE/xicK7p+F+78xXUzFDDJGoFtSg
jyiSS3Vqv/Eo7tQWPcZI0xRlKUMH1X2yerasesodBfUArEU7o7aXP8pv03saU2YG
wITIMV5kKN51+AiqWu7BFFNsf1djBIahGt20vFTJvbKdWMSv/9hqDE2Bm2fW2qZf
Sd5+VF1R9LTIERuvrkR/pOwcDXxOYUf8DBOFVINZOaBAIU3+2cZEXsskyfAfhS3W
aT4DIQA8pVqvn9E4bnopGzWhLgu44IhKlHGEgQIDAQABAoIBAHFO15xwWFLUxTF7
BjsaCk9fxr6aaejM7QHRtq1mjt+jrpoIl/eFXidtZuecv8kVIAyS/Xja3nGvg3Cr
0QSWLi0rLaTCa0juImmUsl72B/EeEpmxDjthquNAlx9G0k8I79GTz+1s4r+xVGgb
60SuQV9Iq2vcmzRT2NXRjJAdcelB+KO+0Vb/y7e5D6QKwbXXSQGOZ2XvQ3/KsO1p
lw1zLmbZ5FtqtXFP469hjjiI30R71kYSpH5tcCDvLrkHbvBiQoiToedPWF8bVnvl
CJRUmXWgVedGc3xciBC63BQ46ebJu+2/4oTcWJMxjPAAN8SRe7hcVCHQhlOLv3gl
76INt2kCgYEA4NDzDzmk6WGbnFRd7dFBiIyhnweMVkRUkcQlq3eW9JZhgkH7Tlzp
kvIZxcWSNwpnLJW1GaUWw2S/VPeESLuWgePIfUPKOdLtAd0/gSPQQC873t8LhtTy
Pvf5pryDG9BiMeg6JwrHUMRkwPX3RjcQM3qTAWzfY7qUuvMZuYg8QC8CgYEAyF34
mH88ixc24HOczRtbAWI7XaQPsFze4K7TlL6MR9umwSw1L67L9FSgDAFjzsYrxzFe
J4mReNNm6RQ0APeJmf4IZju1lQd/VeLr4b43wgtj949K+uqAJLE9q44WZtri+FQy
WIjrvSAwSGrfBwNMLE9whipGUmQCDmpoljdOKk8CgYEAt0/pQNrh6yKZvejVBhuA
chUpnACNn7Hru0fS53OF9T3BmHKwtX7xPc6G0Up+JL8ozaPsnVKNsxktId0JUj0T
RiozymBCPtAMTV7YbzaCkjNxgBMi1PhB5rJQMHK5/S33Q3Z2JGuXhfX9qZFl5Sz0
2uTxhVH+/NSgfafHrA64AiUCgYAZdt/mOZ1vK+cchXTzGDvrpBlZYEViK5tjwLRB
Hipj44WA3WZxBe0Dw1GH1RFjMQpVSW/m5HPpgCx/CMNHMC57tK5Kl+IO66ICP1Gt
IeiiL6Jnzv0/gFgC0ce9qtQsBDt+Re0UFWqoYZPhUDvB/2hJ5VquombHh9A/FsTt
+l9jvwKBgQC8utARFyZbhpa42HSq8JpE2GV4/JHGo+a+jGI4CKus+HYLG4ILL3sd
dsyYppekDo9LOvD7jMCKb2bmNcLeGhihcwzVYSg+ivpO9kVGB8wzpxdTVXKH4bCo
QiaYLGAU81Y0EJrmw1vin6jQY92+JSnou/ZgOKTqWEpvBV4pvOBacA==
-----END RSA PRIVATE KEY-----
DELIM

cat > /etc/ssl/nginx/server.cert <<DELIM
-----BEGIN CERTIFICATE-----
MIIDCzCCAfOgAwIBAgIJAOeMvrD8wE0fMA0GCSqGSIb3DQEBBQUAMBwxGjAYBgNV
BAMMEWluZm9zdGFuZGVyLmxvY2FsMB4XDTE0MDMzMTEwMzYyNVoXDTI0MDMyODEw
MzYyNVowHDEaMBgGA1UEAwwRaW5mb3N0YW5kZXIubG9jYWwwggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQCv9cQciNSr0mIjZyIqMnpr9t1/n/cXGslchiLD
6sU7sYTL6XJF8AtWEyJmllA6jh9iTQC9Nvdm1ObBEO8/e4iwT/GJwrun4X7vzFdT
MUMMkagW1KCPKJJLdWq/8Sju1BY9xkjTFGUpQwfVfbJ6tqx6yh0F9QCsRTujtpc/
ym/TexpTZgbAhMgxXmQo3nX4CKpa7sEUU2x/V2MEhqEa3bS8VMm9sp1YxK//2GoM
TYGbZ9bapl9J3n5UXVH0tMgRG6+uRH+k7BwNfE5hR/wME4VUg1k5oEAhTf7ZxkRe
yyTJ8B+FLdZpPgMhADylWq+f0ThueikbNaEuC7jgiEqUcYSBAgMBAAGjUDBOMB0G
A1UdDgQWBBS2aKYdKQHo9VWVz5a+PUFwubdsRzAfBgNVHSMEGDAWgBS2aKYdKQHo
9VWVz5a+PUFwubdsRzAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBBQUAA4IBAQAj
wmFkHq5NXwqG0QF98tVG+7iU9LqT18gyOjLw/oZeSgE+FI4D1+2ejft838/usE7M
8IEps5apWVJ1RtUv5yiFatxMhbrYEQLiTuMv395MzOiYcnf6Q3hV5cC3ADOquuLq
LRd4KWb2Y7gx0dzO9+bPd5l+JjF3OXNJuGFKhq8K0/UrYz1X+hXQWmDxzUyv8W63
fCtg8B4069q5jh2nk8Zz5PjxWpekQ9kRGhu59vSQa2Bk+lVhlKo4sGF5o22Nu2Es
MPIM5fVpjlk86lZVGGCN97Y1Jghl01p6ZkmIwyd7Heg+Xdc+yTHGWKrzgOOjH9Tr
FRMjoVlMmXmMnDeGuB4l
-----END CERTIFICATE-----
DELIM

# Config file for middleware
cat > /var/www/middleware/config.json <<DELIM
{
  "sitename": "Beta test",
  "port": 3020,
  "ssl": {
    "active": false,
    "key": "/etc/ssl/nginx/server.key",
    "cert": "/etc/ssl/nginx/server.cert",
    "ca": false
  },
  "secret": "THIS IS THE SUPER SECRET KEY",
  "debug": true,
  "log_level": 10,
  "maintenance": {
    "username": "admin",
    "password": "password"
  },
  "cache": {
    "port": "6379",
    "host": "localhost",
    "auth": null
  },
  "backend": {
    "host": "service.indholdskanalen.vm",
    "ip": "127.0.0.1",
    "port": "443"
  },
  "log": "error.log"
}
DELIM

# Config file for client
cat > /var/www/client/js/config.js <<DELIM
window.config = {
  resource: {
    server: '//indholdskanalen.vm/',
    uri: 'proxy'
  },
  ws: {
    server: 'https://indholdskanalen.vm/'
  },
  backend: {
    address: 'https://service.indholdskanalen.vm/'
  },
  cookie: {
    secure: false
  }
}
DELIM

# NodeJS middleware
echo "Installing nodejs"
apt-get install -y python-software-properties python redis-server > /dev/null 2>&1
add-apt-repository ppa:chris-lea/node.js -y > /dev/null 2>&1
sed -i 's/wheezy/lucid/g' /etc/apt/sources.list.d/chris-lea-node_js-wheezy.list
apt-get update > /dev/null 2>&1
apt-get install -y nodejs > /dev/null 2>&1

# Search node requirements
echo "Installing search_node requirements"
su vagrant -c "cd /vagrant/htdocs/search_node && ./install.sh" > /dev/null 2>&1

# Search node config
cd /vagrant/htdocs/search_node/
cp example.config.json config.json

cat > /vagrant/htdocs/search_node/mappings.json <<DELIM
{
  "e7df7cd2ca07f4f1ab415d457a6e1c13": {
    "name": "Indholdskanalen",
    "fields": [
      {
        "field": "title",
        "type": "string",
        "language": "da",
        "country": "DK",
        "default_analyzer": "string_index",
        "sort": true
      }
    ],
    "dates": [ "created_at", "updated_at" ]
  },
  "itkDevShare": {
    "name": "ITK Dev Share",
    "fields": [
      {
        "field": "title",
        "type": "string",
        "language": "da",
        "country": "DK",
        "default_analyzer": "string_index",
        "sort": true
      }
    ],
    "dates": [ "created_at", "updated_at" ]
  },
  "bibShare": {
    "name": "Biblioteks Share",
    "fields": [
      {
        "field": "title",
        "type": "string",
        "language": "da",
        "country": "DK",
        "default_analyzer": "string_index",
        "sort": true
      }
    ],
    "dates": [ "created_at", "updated_at" ]
  }
}
DELIM

# Middleware node requirements
echo "Installing middleware requirements"
su vagrant -c "cd /vagrant/htdocs/middleware && npm install" > /dev/null 2>&1

# Search Node service script
echo "Setting up search_node service"
cat > /etc/init.d/search_node <<DELIM
#!/bin/sh

NODE_APP='app.js'
APP_DIR='/vagrant/htdocs/search_node';
PID_FILE=\$APP_DIR/app.pid
LOG_FILE=\$APP_DIR/app.log
NODE_EXEC=\`which node\`

###############
# chkconfig: - 58 74
# description: node-app is the script for starting a node app on boot.
### BEGIN INIT INFO
# Provides: search_node
# Required-Start:    \$network \$remote_fs \$local_fs
# Required-Stop:     \$network \$remote_fs \$local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: start and stop node
# Description: Node process for app
### END INIT INFO

start_app (){
    if [ -f \$PID_FILE ]
    then
        PID=\`cat $PID_FILE\`
        if ps -p \$PID > /dev/null; then
            echo "\$PID_FILE exists, process is already running"
            exit 1
        else
            rm \$PID_FILE
            start_app
        fi
    else
        echo "Starting node app..."
        if [ ! -d \$APP_DIR ]
        then
            sleep 30
        fi
        cd \$APP_DIR
        \$NODE_EXEC \$APP_DIR/\$NODE_APP  1>\$LOG_FILE 2>&1 &
        echo \$! > \$PID_FILE;
    fi
}

stop_app (){
    if [ ! -f \$PID_FILE ]
    then
        echo "\$PID_FILE does not exist, process is not running"
        exit 1
    else
        echo "Stopping \$APP_DIR/\$NODE_APP ..."
        echo "Killing \`cat \$PID_FILE\`"
        kill \`cat \$PID_FILE\`;
        rm -f \$PID_FILE;
        echo "Node stopped"
    fi
}

case "\$1" in
    start)
        start_app
    ;;

    stop)
        stop_app
    ;;

    restart)
        stop_app
        start_app
    ;;

    status)
        if [ -f \$PID_FILE ]
        then
            PID=\`cat \$PID_FILE\`
            if [ -z "\`ps ef | awk '{print \$1}' | grep "^\$PID\$"\`" ]
            then
                echo "Node app stopped but pid file exists"
            else
                echo "Node app running with pid \$PID"

            fi
        else
            echo "Node app stopped"
        fi
    ;;

    *)
        echo "Usage: \$0 {start|stop|restart|status}"
        exit 1
    ;;
esac
DELIM
chmod +x /etc/init.d/search_node

cp /etc/init.d/search_node /etc/init.d/middleware

# Make middleware service
echo "Making middleware service"
sed -i 's/search_node/middleware/g' /etc/init.d/middleware

# Update rc
update-rc.d middleware defaults > /dev/null 2>&1
update-rc.d search_node defaults > /dev/null 2>&1

# Create database
echo "Setting up database indholdskanalen"
echo "create database indholdskanalen" | mysql -uroot -pvagrant > /dev/null 2>&1

# Copy Angular config file.
cp /vagrant/htdocs/backend/web/js/example.configuration.js /vagrant/htdocs/backend/web/js/configuration.js

# Get composer
echo "Setting up composer"
cd /vagrant/htdocs/backend
curl -sS http://getcomposer.org/installer | php  > /dev/null 2>&1

# Config file for backend_indholdskanalen
cat > /vagrant/htdocs/backend/app/config/parameters.yml <<DELIM
parameters:
  database_driver: pdo_mysql
  database_host: 127.0.0.1
  database_port: null
  database_name: indholdskanalen
  database_user: root
  database_password: vagrant

  mailer_transport: smtp
  mailer_host: 127.0.0.1
  mailer_user: null
  mailer_password: null

  locale: en
  secret: ThisTokenIsNotSoSecretChangeIt

  debug_toolbar:          true
  debug_redirects:        false
  use_assetic_controller: true

  middleware_host: http://127.0.0.1:3020
  absolute_path_to_server: https://service.indholdskanalen.vm

  search_host: http://127.0.0.1:3010
  search_path: /api
  search_customer_id: e7df7cd2ca07f4f1ab415d457a6e1c13

  zencoder_api: 1234567890
DELIM

php composer.phar install  > /dev/null 2>&1
php app/console doctrine:schema:update --force > /dev/null 2>&1

# Setup super-user
echo "Setting up super-user:   admin/admin"
php app/console fos:user:create --super-admin admin test@etek.dk admin > /dev/null 2>&1

# Fix /etc/hosts
echo "Add service.indholdskanalen.vm to hosts"
echo "127.0.1.1 service.indholdskanalen.vm" >> /etc/hosts

# Elastic search
apt-get install openjdk-7-jre -y > /dev/null 2>&1
cd /root
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.4.deb > /dev/null 2>&1
dpkg -i elasticsearch-1.3.4.deb > /dev/null 2>&1
rm elasticsearch-1.3.4.deb
update-rc.d elasticsearch defaults 95 10 > /dev/null 2>&1

# Elasticsearch plugins
/usr/share/elasticsearch/bin/plugin -install elasticsearch/elasticsearch-analysis-icu/2.3.0 > /dev/null 2>&1
/usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head > /dev/null 2>&1

echo "Starting php5-fpm"
service php5-fpm start > /dev/null 2>&1

echo "Starting nginx"
service nginx restart > /dev/null 2>&1

echo "Starting mysql"
service mysql start > /dev/null 2>&1

echo "Starting ElasticSearch"
service elasticsearch restart > /dev/null 2>&1

echo "Starting redis"
service redis-server restart > /dev/null 2>&1

echo "Starting search_node"
service search_node start > /dev/null 2>&1

echo "Starting middleware"
service middleware start > /dev/null 2>&1

echo "Done"
