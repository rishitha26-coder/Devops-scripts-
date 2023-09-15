#!/bin/bash

shopt -s extglob

fulldescription=()
if [[ ! -n "$1" ]] ; then
	echo "No arguments, so reading summary and description interactively for the jira ticket you want to create."
	echo "Please provide a brief summary of the ticket, also used as the first line of the description:"
	read summary
	[[ -n "${summary}" ]] || exit 1
	echo "Please provide a more extensive description of the ticket, hitting enter on a blank line when done."
	fulldescription[0]="${summary}"
	a=1
	while true ; do
		read description
		[[ -n $description ]] || break
		fulldescription[$a]=${description}
		let a++
	done
	[[ "$a" -gt "0" ]] || exit 1
        JIRA_ISSUE=$(${0%/*}/makeJiraIssue.py "$summary" "${fulldescription[@]}" "$USER@mogo.ca" | awk '$1 ~ /Created/ {print $3}' || exit 1)
else
	JIRA_ISSUE=${1}
fi


echo $JIRA_ISSUE

if [[ -n "$JIRA_ISSUE" ]] ; then
        git pull
	git branch $JIRA_ISSUE
	git checkout $JIRA_ISSUE
fi
