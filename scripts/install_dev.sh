#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

script_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../htdocs/admin && pwd)
bundles_dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../htdocs/bundles && pwd)

echo "${bold}composer install'ing local bundles${normal}"

cd $dir
rm -fr vendor
COMPOSER=$dir/../../scripts/composer-dev.json composer install

bundles=$(ls -d $bundles_dir/*/*)

cat <<EOF

Now, go to any of

$bundles

and check out the branch you want to work on.

EOF
