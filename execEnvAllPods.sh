#!/bin/bash

export SCRIPT_DIR=${0%/*}
if [[ "$SCRIPT_DIR" != */* ]] ; then
	SCRIPT="$(which $0)"
	export SCRIPT_DIR="${SCRIPT%/*}"
elif [[ "$SCRIPT_DIR" = "$0" ]] || [[ "$SCRIPT_DIR" == "." ]] ; then
        export SCRIPT_DIR="$(pwd)"
fi
. ${SCRIPT_DIR}/eks-common.include


APP="$1"

shift

for pod in $(kubectl --context=${EKS_ENV} -n ${NAMESPACE} get pods -l app=${APP} | awk "\$1 ~ /^${APP}/ {print \$1}") ; do
	#echo "### running $@ on $pod ###"
	kubectl --context=${EKS_ENV} -n ${NAMESPACE} exec -it pod/${pod} -- "${@}"
done
