#!/bin/bash

rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}

GITHUB_URL="$(git config --get remote.origin.url | sed -e 's;.*github.com.;https:\/\/github.com\/;g' -e 's/\.git//g')"
echo $GITHUB_URL
GIT_DEFAULT_BRANCH="${1:-$(git config --get branch.master.merge | sed 's;.*/;;g')}"
GIT_DEFAULT_BRANCH="${GIT_DEFAULT_BRANCH:-$(git config --get branch.dev.merge | sed 's;.*/;;g')}"
GIT_DEFAULT_BRANCH="${GIT_DEFAULT_BRANCH:-$(git config --get branch.develop.merge | sed 's;.*/;;g')}"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
GIT_COMMITS="${GIT_BRANCH} - $( git log --pretty=format:"%an %s" ${GIT_DEFAULT_BRANCH}..${GIT_BRANCH} )"
git push --set-upstream origin ${GIT_BRANCH}
gh pr create --fill --base "${GIT_DEFAULT_BRANCH}"
open $(gh pr view -q .url --json url)/files
#GIT_COMMITS="$( git log --pretty=format:"%an %s" ${GIT_DEFAULT_BRANCH}..${GIT_BRANCH} | tr '\n' '%5Cn' | sed -e 's/ /+/g' -e 's/\?//g')"

#open ${GITHUB_URL}/compare/${GIT_DEFAULT_BRANCH}..${GIT_BRANCH}
#open "${GITHUB_URL}/compare/${GIT_BRANCH}?expand=1\&title=${GIT_BRANCH}\&body=${GIT_COMMITS}"
#echo $GIT_COMMITS
#echo open "${GITHUB_URL}/pull/new/${GIT_BRANCH}?quick_pull=1&title=${GIT_BRANCH}&body=$(rawurlencode "${GIT_COMMITS}")"
#open "${GITHUB_URL}/pull/new/${GIT_BRANCH}?quick_pull=1&title=$(rawurlencode ${GIT_BRANCH})&body=$(rawurlencode "${GIT_COMMITS}")"
