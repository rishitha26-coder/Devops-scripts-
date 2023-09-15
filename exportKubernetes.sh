#!/bin/bash

KUBECTL="kubectl $1"

${KUBECTL} get namespaces


namespaces=($(${KUBECTL} get namespaces | awk '$1 !~ /^NAME/ {print $1}'))

if [[ "$1" != *context=* ]] ; then
	currentcontext="$(${KUBECTL} config current-context)"

	if [[ ! -n "$currentcontext" ]] || [[ ! -n "$namespaces" ]] ; then
		echo 'There was an issue running kubectl, or there is no context set with "kubectl config use-context".'
		echo 'Use "aws sso login --profile=mogo-XXXXXX" first to log in properly and set your context with kubectl.'
		echo 'run "kubectl config get-contexts" to find out what contexts you have configured.'
		exit 1
	fi
else
	currentcontext="$(echo "$1" | sed -e 's/.*context=//g')"
	shift
fi

[[ -n "$currentcontext" ]] || exit 1

directory=${currentcontext}-export-$(date +%F)


APPEND_ONLY=
if [[ -d "$directory" ]] ; then
	echo "Directory $directory already exists! Should we append (grabbing new config items only), overwrite (rewrite all config items) or abort? "
	read answer
	if [[ "$answer" == "append" ]] ; then
		APPEND_ONLY=true
	elif [[ "$answer" != "overwrite" ]] ; then
		echo "Aborting!"
		exit 1
	fi
fi

echo Arguments $@
WITH_SECRETS=
if [[ "$1" == "--include-secrets" ]] ; then
	WITH_SECRETS=true
	echo "You've asked to export kubernetes secrets! Only do this if you must, and please protect them by putting them on an encrypted volume and deleting them as soon as possible!"
	echo "Type: 'I will protect them with my life' if you understand"
	read answer
	[[ "$answer" == "I will protect them with my life" ]] || { echo Aborting! ; exit 1 ; }
fi

echo "About to export kubernetes config from $currentcontext, including the namespaces ${namespaces[@]}."
if [[ ! -n ${WITH_SECRETS} ]] ; then
	echo "If you wanted to export secrets then run ${0} --include-secrets"
fi
echo -n "Press enter to continue or hit CTRL-C to abort now!"
read answer

mkdir -p $directory || exit 1

resources=($(${KUBECTL} api-resources --verbs=list --namespaced -o name | grep -v "events" | grep -v secrets | sort | uniq))

for namespace in ${namespaces[@]} ; do
	[[ -n "$namespace" ]] || continue
	mkdir -p ${directory}/${namespace}
	echo "#### Exporting namespace $namespace ####" | tee $directory/${namespace}/cluster-state.txt
	${KUBECTL} get namespace $namespace
	for resource in ${resources[@]} ; do
		resourcelist=($(${KUBECTL} get $resource -n $namespace  | awk '$1 !~ /^NAME/ {print $1}'))
		[[ -n "${resourcelist[@]}" ]] || continue
		echo "Exporting resource $resource from $namespace in $currentcontext.... "
		echo "## Resource $resource status from $namespace in $currentcontext at $(date) ##" >> $directory/${namespace}/cluster-state.txt
		${KUBECTL} get $resource -n $namespace  >> $directory/${namespace}/cluster-state.txt || exit 1
		mkdir -p $directory/${namespace}/${resource}/
		for resourcename in ${resourcelist[@]} ; do
			if [[ -n "$APPEND_ONLY" ]] && [[ -s "$directory/${namespace}/${resource}/${resourcename}.yaml" ]] ; then
				continue
			fi
			${KUBECTL} get $resource $resourcename -n $namespace -o yaml > $directory/${namespace}/${resource}/${resourcename}.yaml || exit 1
		done
	done
	[[ -n "$WITH_SECRETS" ]] || continue
	echo "## Exporting secrets from $namespace in $currentcontext.... ##"
	echo "## Secrets in $namespace on $currentcluster at $(date) ##" >> $directory/${namespace}/cluster-state.txt || exit 1
	secretlist=($(${KUBECTL} get secrets -n $namespace | awk '$1 !~ /NAME/ {print $1}'))
	mkdir -p ${directory}/${namespace}/secrets
	for secret in ${secretlist[@]} ; do
		[[ -n "$secret" ]] || continue
		if [[ -n "$APPEND_ONLY" ]] && [[ -s "$directory/${namespace}/secrets/${resourcename}.yaml" ]] ; then
			continue
		fi
		${KUBECTL} get secret -n $namespace $secret -o yaml > ${directory}/${namespace}/secrets/${secret}.yaml || exit 1
	done
done
