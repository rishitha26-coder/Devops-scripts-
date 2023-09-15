#!/bin/bash

GITHUB_URL="$(git config --get remote.origin.url | sed -e 's;.*github.com.;https:\/\/github.com\/;g' -e 's/\.git//g')"
echo $GITHUB_URL
GIT_MERGE_BRANCH="${1:-$(git config --get branch.master.merge | sed 's;.*/;;g')}"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
#GIT_COMMITS="${GIT_BRANCH} - $( git log --pretty=format:"%an %s" ${GIT_MERGE_BRANCH}..${GIT_BRANCH} )"

gh repo edit --enable-rebase-merge --enable-squash-merge --enable-merge-commit --delete-branch-on-merge --allow-update-branch || exit 1

MERGE_TEXT="Merging ${GIT_BRANCH} into ${GIT_MERGE_BRANCH} #transition pending-deployment"

gh pr merge -d -s -b "${MERGE_TEXT}" --admin || gh pr merge -d -r -b "${MERGE_TEXT}" --admin || exit 1

git checkout ${GIT_MERGE_BRANCH} && git pull




#GIT_COMMITS="$( git log --pretty=format:"%an %s" ${GIT_MERGE_BRANCH}..${GIT_BRANCH} | tr '\n' '%5Cn' | sed -e 's/ /+/g' -e 's/\?//g')"

#open ${GITHUB_URL}/compare/${GIT_MERGE_BRANCH}..${GIT_BRANCH}
#open "${GITHUB_URL}/compare/${GIT_BRANCH}?expand=1\&title=${GIT_BRANCH}\&body=${GIT_COMMITS}"
#echo $GIT_COMMITS
#echo open "${GITHUB_URL}/pull/new/${GIT_BRANCH}?quick_pull=1&title=${GIT_BRANCH}&body=$(rawurlencode "${GIT_COMMITS}")"
#open "${GITHUB_URL}/pull/new/${GIT_BRANCH}?quick_pull=1&title=$(rawurlencode ${GIT_BRANCH})&body=$(rawurlencode "${GIT_COMMITS}")"
