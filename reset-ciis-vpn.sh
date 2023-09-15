#!/bin/bash

AWS_PROFILE=mogo-vpn AWS_REGION=ca-central-1 aws ec2 modify-vpn-connection-options --vpn-connection-id vpn-0af2af3ff647df847 --local-ipv4-network-cidr 142.148.126.0/24 --remote-ipv4-network-cidr 10.64.0.0/11
