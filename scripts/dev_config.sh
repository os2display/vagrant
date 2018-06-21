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

#
for vendor_dir in $packages_dir/*/ ; do
    vendor=$(basename "$vendor_dir")
    echo $vendor

    for package_dir in $vendor_dir/*/ ; do
        package=$(basename "$package_dir")
        echo - $package

		COMPOSER=$dir/$composer_dev composer config repositories.$vendor/$package path ../../packages/$vendor/$package
    done
done

# Install packages.
rm -rf $dir/vendor/

cd $dir
COMPOSER=composer-dev.json composer install
cd ../..
