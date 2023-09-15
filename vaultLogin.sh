#!/bin/bash
vault login -method=github token=$(security find-generic-password -a ${USER} -s github-vault -w)
