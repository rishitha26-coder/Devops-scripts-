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

kubectl --context=${EKS_ENV} -n ${NAMESPACE} exec -it deployment/${APP} -- "${@}"


