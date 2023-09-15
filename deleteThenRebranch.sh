#!/bin/bash

BRANCH=${1:-$(git branch --show-current)}

git pull 

git checkout ${2:-$(git config --get branch.master.merge | sed 's;.*/;;g')} || exit 1

git pull || exit 1

git branch $BRANCH --delete || exit 1

git branch $BRANCH || exit 1

git checkout $BRANCH
