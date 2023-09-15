#!/bin/bash

shopt -s extglob

DELAY=1.1s

. /Volumes/Private\ Keys/datadog.config
TEMPFILE="$(mktemp /var/tmp/${0##*/}.XXXXXX)"

DESTDIR="${5:-$(mktemp -d /var/tmp/${0##*/}.XXXXXX)}"

mkdir -p "$DESTDIR" || exit 1

CURSOR=
DESTFILENUM=0

logquery=

incrementDestfile () {
	let DESTFILENUM++
	DESTFILE=${DESTDIR}/${DESTFILENUM}.json
	}

runCurl () {
	# Curl command
	curl -s -X POST "https://api.datadoghq.com/api/v2/logs/events/search" \
	-H "Content-Type: application/json" \
	-H "DD-API-KEY: ${DD_API_KEY}" \
	-H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
	-d @${TEMPFILE} | jq .
	}

makeDataFile () {
cat << EOF 
{
"filter": {
	"from":"${2:-now-1w}",
	"query": "$1",
	"to": "${3:-now}"
	},
"options": {
        "timezone": "GMT"
        },
"page": {
	${CURSOR}
       "limit": ${4:-1000}
        }
}
EOF
	}

incrementDestfile || exit 1
makeDataFile "$@" > $TEMPFILE
runCurl | tee $DESTFILE || { cat ${DESTFILE} ; exit 1 ; }

NEXTPAGE="$(jq .meta.page.after ${DESTFILE})"
ERROR="$(jq .code ${DESTFILE})|$(jq .error ${DESTFILE})"

while [[ "$NEXTPAGE" != "null" ]] && [[ "$ERROR" == "null|null" ]] ; do
	sleep ${DELAY} > /dev/null 2>&1 &
	[[ -s "$TEMPFILE3" ]] || TEMPFILE3="$(mktemp /var/tmp/${0##*/}.XXXXXX)"
	CURSOR='"cursor":'${NEXTPAGE}','
	incrementDestfile
	makeDataFile "$@" > $TEMPFILE
	runCurl | tee $DESTFILE
	NEXTPAGE="$(jq .meta.page.after ${DESTFILE})"
	ERROR="$(jq .code ${DESTFILE})|$(jq .error ${DESTFILE})"
	#cat ${TEMPFILE}
	wait
done

if [[ -n "$ERROR" ]] ; then
	echo ## Error processing query: $ERROR
	echo ## Query:
	cat $TEMPFILE
fi

rm -f ${TEMPFILE} ${TEMPFILE3}

[[ -d "$5" ]] || rm -fr ${DESTFILE}

#"indexes"="["main","index-3-days","index-7-days","index-30-days"],
#	"query": "@haproxy.response.code:200 AND @http.url_details.path:\/sessions\/trans\/_sessions_* AND @haproxy.request.header.X-Mogo-Client:android-v4.15.1",
