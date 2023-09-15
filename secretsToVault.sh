#!/bin/bash

kubectl get namespaces

if [[ ! -s "$1" ]] ; then
	echo "Usage: ${0} configfile [ namespaces ]"
	exit 1
fi

export VAULT_NAMESPACE=admin

vaultLogin.sh

export VAULT_TOKEN="$(vault token lookup | awk '$1 ~ /^id$/ {print $2}')"

VARIABLES_FILE="$1"

. "${VARIABLES_FILE}"

shift

echo "Checking for secrets at ${SECRETS_BASE}"

vault kv list ${SECRETS_BASE} || exit 1

if [[ -n "$1" ]] ; then
	namespaces=("$@")
else
	namespaces=($(kubectl --context=${KUBECTL_CONTEXT} get namespace | awk '$1 !~ /^NAME/ {print $1}'))
fi

if [[ ! -n "$namespaces" ]] ; then
	echo 'There was an issue running kubectl, or there is no context set with KUBECTL_CONTEXT in ${VARIABLES_FILE}.'
	echo 'Use "aws-vault login mogo-k8s" first to log in properly and set your context with kubectl.'
	exit 1
fi

echo "About to export kubernetes secrets from $currentcontext for the following namespaces ${namespaces[@]}."

echo -n "Press enter to continue or hit CTRL-C to abort now!"
read answer

for namespace in ${namespaces[@]} ; do
	[[ -n "$namespace" ]] || continue
	kubectl get namespace $namespace || continue
	echo "## Exporting secrets from $namespace in $currentcontext.... ##"
	echo "## Secrets in $namespace on $currentcluster at $(date) ##" 
	secretlist=($(kubectl get secrets -n $namespace | awk '$1 !~ /NAME/ {print $1}'))
	for secret in ${secretlist[@]} ; do
		[[ -n "$secret" ]] || continue
		kubectl --context=${KUBECTL_CONTEXT} get secret -n $namespace $secret -o json | jq .data | vault kv put ${SECRETS_BASE}/${namespace}/${secret} -
	done
done
