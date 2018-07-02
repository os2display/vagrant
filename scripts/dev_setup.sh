#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

base_dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../ && pwd)

cd $base_dir

mkdir packages
cd packages

mkdir os2display
cd os2display

function clone_latest {
  git clone --branch=master https://github.com/os2display/$1.git

#  If you can use ssh access to the git repository, you can do this instead:
#  git clone --branch=master git@github.com:os2display/$1.git

  cd $1

  latesttag=$(git describe --tags)
  echo checking out ${latesttag}
  git checkout ${latesttag}

  cd ..
}

BUNDLES="core-bundle
media-bundle
admin-bundle
default-template-bundle"

for BUNDLE in $BUNDLES
do
(
    clone_latest $BUNDLE
)
done

cd ..

cd ..
