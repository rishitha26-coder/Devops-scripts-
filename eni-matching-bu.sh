#!/bin/bash

aws ec2 --profile=mogo --output=json describe-instances --query 'Reservations[].Instances[].{Name: Tags[?Key==`Name`].Value | [0], Description: Tags[?Key==`Description`].Value | [0], Business_Unit: Tags[?Key==`Business_Unit`].Value | [0], ID: InstanceId, Type: InstanceType, Network_Interfaces: NetworkInterfaces[*].NetworkInterfaceId, Storage_Volumes: BlockDeviceMappings[*].Ebs.VolumeId }' | jq -r '.[] | select(.Business_Unit == "'$1'") | .Network_Interfaces' | grep eni | sed -e 's/"//g' -e 's/,//g'
