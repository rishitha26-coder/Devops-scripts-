#!/bin/bash

basebranch=$(git config --list | grep '.merge=' | sed 's/.*=//g')

basebranch="${2:-${basebranch}}"
[[ -n "$basebranch" ]] || exit 1

git merge -X ${1:-theirs} -m 'merge from ${1:-${basebranch}} upstream branch' ${2:-${basebranch}}
