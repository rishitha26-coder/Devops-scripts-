#!/bin/bash

#mogo
#mogo-cre
accounts=(
mogo-devops
mogo-dev
mogo-sec
mogo-vpn
mogo-soa-staging
mogo-soa-nonprod
mogo-soa-qa
mogo-soa-nonprod-or
mogo-soa-prod
mogo-soa-prod-or
mogo-soa-training
mogo-soa-dev
mogo-keyspaces
mogo-sandbox
mogo-aaron
mogo-eks
mogo-ca-dev
)

bus=(
mogo
devops
trade
it
crm
bi
fs
)

a=0
for account in ${accounts[@]} ; do
  let a++
  export AWS_PROFILE=$account
  echo In AWS ACCOUNT: $AWS_PROFILE
  for bu in ${bus[@]} ; do
    echo Tagging resources for $bu in $AWS_PROFILE
    export AWS_PROFILE=$account
    objects=
    instancecommand="aws ec2 --output=json  describe-instances --filters 'Name=instance-state-name,Values=running' --query 'Reservations[].Instances[].{Name: Tags[?Key==\`Name\`].Value | [0], Description: Tags[?Key==\`Description\`].Value | [0], Business_Unit: Tags[?Key==\`Business_Unit\`].Value | [0], ID: InstanceId, Type: InstanceType, Network_Interfaces: NetworkInterfaces[*].NetworkInterfaceId, Storage_Volumes: BlockDeviceMappings[*].Ebs.VolumeId }'"
    objects=$(aws ec2 --output=json  describe-instances --query 'Reservations[].Instances[].{Name: Tags[?Key==`Name`].Value | [0], Description: Tags[?Key==`Description`].Value | [0], Business_Unit: Tags[?Key==`Business_Unit`].Value | [0], ID: InstanceId, Type: InstanceType, Network_Interfaces: NetworkInterfaces[*].NetworkInterfaceId, Storage_Volumes: BlockDeviceMappings[*].Ebs.VolumeId }' | tee objects.list | jq -r '.[] | select(.Business_Unit == "'$bu'") | .Storage_Volumes, .Network_Interfaces' | grep - | sed -e 's/"//g' -e 's/,//g'    )
    [[ -n "$objects" ]] || continue
    echo running aws ec2 create-tags --tags Key=Business_Unit,Value=${bu} --resources $objects
    aws ec2 create-tags --tags Key=Business_Unit,Value=${bu} --resources $objects && continue
# For debugging one at a time
#    for object in $objects ; do
#      export AWS_PROFILE=$account
#      aws ec2 create-tags --tags Key=Business_Unit,Value=${bu} --resources $object && continue
#      echo error running: aws ec2 create-tags --tags Key=Business_Unit,Value=${bu} --resources $object
#      echo instances derived from $instancecommand
#      break 3
#    done
  done
done
