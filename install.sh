#!/usr/bin/env bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

bold=$(tput bold)
normal=$(tput sgr0)

cd $DIR

if [ -e $DIR/htdocs ]
then
		echo "${bold}Directory $DIR/htdocs already exists. Please remove it before running this script:${normal}"
		echo
		echo "rm -fr $DIR/htdocs"
		echo
		exit
fi

echo "${bold}Cloning repositories${normal}"
mkdir htdocs
cd htdocs

git clone git@github.com:search-node/search_node.git search_node

git clone git@github.com:os2display/docs.git docs
git clone git@github.com:os2display/admin.git admin
git clone git@github.com:os2display/middleware.git middleware
git clone git@github.com:os2display/screen.git screen
cd ..
