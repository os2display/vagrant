#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

packages_dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../packages/ && pwd)
dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../htdocs/admin/ && pwd)

# Copying composer.json to composer-dev.json
composer_dev=composer-dev.json

if [ ! -e $dir/composer.json ]; then
		(>&2 echo File composer.json not found in $dir)
		exit
fi

if [ -e $dir/$composer_dev ]; then
		(>&2 echo File $dir/$composer_dev already exists)
		exit
fi

cp -v $dir/composer.json $dir/$composer_dev

COMPOSER_PATH="$(which composer)"

for vendor_dir in $packages_dir/*/ ; do
    vendor=$(basename "$vendor_dir")
    echo $vendor

    for package_dir in $vendor_dir/*/ ; do
        package=$(basename "$package_dir")
        echo - $package

        COMPOSER=$dir/composer-dev.json php -d memory_limit=-1 $COMPOSER_PATH config repositories.$vendor/$package path ../../packages/$vendor/$package
    done
done

rm -rf $dir/vendor/os2display

# Install packages.
cd $dir
COMPOSER=$dir/composer-dev.json php -d memory_limit=-1 $COMPOSER_PATH install
app/console assets:install --symlink --relative
cd ../..
