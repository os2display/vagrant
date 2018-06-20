#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

base_dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../ && pwd)

cd $base_dir

mkdir packages
cd packages

mkdir aakb
cd aakb
git clone --branch=master git@github.com:aakb/os2display-aarhus-templates
cd ..

mkdir os2display
cd os2display

git clone --branch=master git@github.com:itk-os2display/core-bundle
git clone --branch=master git@github.com:itk-os2display/media-bundle
git clone --branch=master git@github.com:itk-os2display/admin-bundle
git clone --branch=master git@github.com:itk-os2display/default-template-bundle
cd ..

mkdir itk-os2display
cd itk-os2display

git clone --branch=master git@github.com:itk-os2display/aarhus-data-bundle
git clone --branch=master git@github.com:itk-os2display/aarhus-second-template-bundle
git clone --branch=master git@github.com:itk-os2display/campaign-bundle
git clone --branch=master git@github.com:itk-os2display/exchange-bundle
git clone --branch=master git@github.com:itk-os2display/horizon-template-bundle
git clone --branch=master git@github.com:itk-os2display/lokalcenter-template-bundle
git clone --branch=master git@github.com:itk-os2display/template-extension-bundle
git clone --branch=master git@github.com:itk-os2display/vimeo-bundle
git clone --branch=master git@github.com:itk-os2display/os2display-koba-integration
cd ..

cd ..
cd ..
