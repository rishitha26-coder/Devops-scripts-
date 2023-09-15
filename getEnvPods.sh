#!/bin/bash

export SCRIPT_DIR=${0%/*}
if [[ "$SCRIPT_DIR" = "$0" ]] || [[ "$SCRIPT_DIR" == "." ]] ; then
        export SCRIPT_DIR="$(pwd)"
fi
. ${SCRIPT_DIR}/eks-common.include

kubectl --context=${EKS_ENV} -n ${NAMESPACE} get pods -l app=${1}
