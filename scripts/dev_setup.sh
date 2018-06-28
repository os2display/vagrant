#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

base_dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../ && pwd)

cd $base_dir

mkdir packages
cd packages

mkdir os2display
cd os2display

git clone --branch=master git@github.com:os2display/core-bundle
git clone --branch=master git@github.com:os2display/media-bundle
git clone --branch=master git@github.com:os2display/admin-bundle
git clone --branch=master git@github.com:os2display/default-template-bundle
cd ..

cd ..
