#!/bin/bash

export VAULT_ADDR=https://vault.security.mogok8s.net

export AWS_PROFILE=moka-bi
export AWS_REGION=ca-central-1

eval $(vault kv get -format=json secrets/devops/sensitive/moka-redshift | jq -r '.data.data| to_entries|map("\(.key)=\(.value|tostring)")|.[]' | sed 's/^/export /g')

#endpoint=$(aws redshift describe-clusters --cluster-identifier bi --output json | jq -r '.Clusters[0].Endpoint.Address')
#port=$(aws redshift describe-clusters --cluster-identifier bi --output json | jq -r '.Clusters[0].Endpoint.Port')
export PGPASSWORD=$(aws redshift get-cluster-credentials --db-user mylo --cluster-identifier bi | awk '{print $1}')
export PGUSER="IAM:mylo"

#psql -h $endpoint -p $port -U $user
psql
env | grep -i pg

