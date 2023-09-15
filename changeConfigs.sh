#!/bin/bash

[[ -d "$1" ]] || exit 1

[[ -d "$2" ]] && exit 1
[[ -f "$2" ]] && exit 1

mkdir -p $2 || exit 1

SEDFILES=($(grep --files-with-matches 'extensions/v1beta1' -r $1))

for file in ${SEDFILES[@]} ; do
	destfile=${file//\//_}
	destfile=${destfile%.yaml}
	destfile="${destfile//./_}.yaml"
	destfile=${destfile#_}
	if [[ "$destfile" == *deployments_apps* ]] ; then
		sed -e 's;extensions/v1beta1;apps/v1;g' $file > ${2}/${destfile}
	elif [[ "$destfile" == *daemonsets_apps* ]] ; then
		sed -e 's;extensions/v1beta1;apps/v1;g' $file > ${2}/${destfile}
	elif [[ "$destfile" == *ingresses_networking* ]] ; then
		sed -e 's;extensions/v1beta1;networking.k8s.io;g' $file > ${2}/${destfile}
	fi
done
