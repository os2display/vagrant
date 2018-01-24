#!/usr/bin/env bash
bold=$(tput bold)
normal=$(tput sgr0)

script_dir=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
dir=$(cd $(dirname "${BASH_SOURCE[0]}")/../htdocs/ && pwd)

get_bundles() {
	bundles_dir=$dir/bundles
	mkdir -p $bundles_dir/$name
	cd $bundles_dir/$name
	for bundle in ${bundles[@]}; do
		tokens=(${bundle//@/ })
		repo=${tokens[0]}
		branch=${tokens[1]:-master}
		echo "${bold}$name/$repo@$branch -> $bundles_dir/$name/$repo${normal}"
		if [ ! -d $repo ]; then
				git clone https://github.com/$name/$repo.git
		fi
		git -C $repo fetch --quiet
		git -C $repo checkout $branch --quiet
		git -C $repo log --oneline --max-count=1
		echo
	done
}

name=itk-os2display
bundles=(
		aarhus-data-bundle@1.1.1
		aarhus-second-template-bundle@1.0.4
		admin-bundle@1.0.13
		campaign-bundle@develop
		core-bundle@1.0.14
		default-template-bundle@1.0.8
		exchange-bundle@1.0.1
		horizon-template-bundle@1.0.3
		lokalcenter-template-bundle@1.0.5
		media-bundle@1.0.2
		template-extension-bundle@1.1.11
		vimeo-bundle@1.0.1
		os2display-koba-integration@1.0.5
)

get_bundles

name=aakb
bundles=(
	os2display-aarhus-templates@1.0.15
)

get_bundles

cat <<EOF

To install stuff, run:

 $script_dir/install_dev.sh

EOF
