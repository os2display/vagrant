#!/usr/bin/env bash
# Checks out the branch for all packages.

bold=$(tput bold)
normal=$(tput sgr0)

packages_dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../packages && pwd)

branch="$1"

if [ -z "$branch" ]; then
		cat <<EOF >&2

Usage: $0 <branch>

EOF
		exit
fi

for d in $packages_dir/*/*; do
	echo "${bold}$d${normal}"
	git -C $d fetch
	git -C $d rev-parse --quiet --verify "$branch" 2>&1 > /dev/null
	if [ $? -eq 0 ]; then
			git -C $d checkout "$branch"
			git -C $d pull
	else
		(>&2 echo "Branch $branch does not exist")
	fi
	echo
done
