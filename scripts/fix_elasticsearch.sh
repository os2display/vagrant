#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

if [ -d "/vagrant" ]; then
    sudo mkdir -p /var/run/elasticsearch
    sudo chown elasticsearch /var/run/elasticsearch
    sudo service elasticsearch start
    sudo service supervisor restart
else
    echo "Make sure to run it inside the vagrant (vagrant ssh)!"
fi
