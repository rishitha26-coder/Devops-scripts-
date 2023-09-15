#!/bin/bash

curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg ./AWSCLIV2.pkg -target /

echo "For most purposes, ca-central-1 for sso region, then us-west-2 for the region."
echo "Setting up a friendly name rather than 'AdministratorAccess/XXXXX' is also recommended"

aws configure sso
