#!/bin/bash

shopt -s extglob

export SCRIPT_DIR=${0%/*}
if [[ "$SCRIPT_DIR" = "$0" ]] || [[ "$SCRIPT_DIR" == "." ]] ; then
        export SCRIPT_DIR="$(pwd)"
fi

if [[ ! -s ${SCRIPT_DIR}/terraformer.variables ]] ; then
	echo -n "Create a new terraformer.variables file? Note: you should copy this script to a new blank directory before doing this. (y/n)" 2>&1
	read -n 1 answer
	echo
	[[ "$answer" == @(y|Y) ]] || exit 1
	cat <<EOF > ${SCRIPT_DIR}/terraformer.variables
# This is the list of resources you want included. By default, it will be all of them in the terraformer repo (you should have downloaded this!)
resourcelist=(\$(ls ~/repos/terraformer/providers/aws | cut -d '/' -f 2 | cut -d '.' -f 1))
# This is the list of profiles to pull from. Note: if you have multiple profiles and resources, this could take a while! The list is space separated
profiles=(mogo)
# This is the regions to pull from. These apply to *each* profile. The list is space separated.
regions=(us-west-2)
EOF
	echo "${SCRIPT_DIR}/terraformer.variables created! Please edit then run again."
	exit 0
fi

. ${SCRIPT_DIR}/terraformer.variables

VERSION=3.44.0
for profile in ${profiles[@]} ; do 
	/usr/local/bin/aws sso login --profile=$profile || exit 1
done

mydate="$(date +%F_%H-%M)"

rootdirectory=$(pwd)
for profile in ${profiles[@]} ; do
	for region in ${regions[@]} ; do 
		basedir="${profile}/${region}/aws"
		rm -fr ${profile}/${region}/aws/*.backup
		for resource in ${resourcelist[@]} ; do 
			resourcedir="${basedir}/${resource}"
			[[ -d ${resourcedir} ]] &&  mv ${resourcedir} ${resourcedir}.${mydate}
			terraformer import aws --profile=${profile} --resources="$resource" --path-pattern ${profile}/${region}/'{provider}/{service}' --regions $region
			if ! ls ${resourcedir}/*.tf 2>/dev/null | grep -q -v provider.tf ; then
				echo no resources of type ${resource} for ${profile} in ${region} 
				 rm -fr ${resourcedir}
			fi
			#cd ${rootdirectory}/${profile}/aws/all || continue
		done
	done
cat << EOF > provider.tf
provider "aws" {
  region = "ca-central-1"
  profile = "${profile}"
}

terraform {
	required_providers {
		aws = {
	    version = "~> ${VERSION}"
		}
  }
}
EOF

	terraform state replace-provider --auto-approve registry.terraform.io/-/aws hashicorp/aws > /dev/null || continue
	terraform init || continue
	AWSPROFILE=${profile} terraform plan || continue
done
