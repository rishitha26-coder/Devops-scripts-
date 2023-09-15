#!/bin/bash

shopt -s extglob

AWS_ARGS="--output=json --output yaml-stream"

AWS=$(which aws)

export AWS_PROFILE=moka-master
export AWS_REGION=ca-central-1

if ! ${AWS} sts get-caller-identity ; then
        echo "Attempting to log you into AWS. You must be logged in to execute anything! You must also be using sso and aws cli version 2"
        ${AWS} sso login --profile=${AWS_PROFILE} $AWS_ARGS || { which ${AWS} ; ${AWS} --version ;}
fi

getProcessList () {
  aws ecs describe-tasks --cluster=$CLUSTER --output=json \
    --query "tasks[?(createdAt<'$(date -v -1d +%F)') && (group=='family:${PROCESS}')].[taskArn]" \
    --tasks $(aws ecs list-tasks --max-items=50 --cluster=$CLUSTER --output=json  | \
                jq -r '.taskArns | to_entries | .[].value') | \
          jq -r '.[] | to_entries | .[].value'
   }

CLUSTER=ecs-cluster-prd
PROCESS=cashescort-processes

CASHESCORT_LIST=($(getProcessList))
echo CashEscort Processes to kill:
echo ${CASHESCORT_LIST[@]}

CLUSTER=production-cluster
PROCESS=admin-scripts

ADMINSCRIPTS_LIST=($(getProcessList))

echo Admin scripts processes to kill:
echo ${ADMINSCRIPTS_LIST[@]}

if [[ "$1" != "--force" ]] && [[ -n "${ADMINSCRIPTS_LIST}${CASHESCORT_LIST}" ]] ; then
  echo 
  echo "Stop all these processes? (y/N)"
  read -n 1 answer
  if [[ "$answer" != @(y|Y) ]] ; then
    exit 0
  fi
fi

for cashescorttask in ${CASHESCORT_LIST[@]} ; do
  echo Stopping $cashescorttask
  aws ecs stop-task --cluster ecs-cluster-prd --task $cashescorttask ${AWS_ARGS} | cat || exit 1
done

for admintask in ${ADMINSCRIPTS_LIST[@]} ; do
  echo stopping $admintask
  aws ecs stop-task --cluster production-cluster --task $admintask ${AWS_ARGS} | cat || exit 1
done
