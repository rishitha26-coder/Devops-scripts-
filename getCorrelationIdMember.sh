#!/bin/bash

. /Volumes/Private\ Keys/datadog.config

# Curl command
curl -X POST "https://api.datadoghq.com/api/v2/logs/events/search" \
-H "Content-Type: application/json" \
-H "DD-API-KEY: ${DD_API_KEY}" \
-H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
-d @- << EOF 2> /dev/null | tee ~/incident/${1}.json | sed 's/}/}\n/g' | grep email_address | sed -e 's/.*email_address":"//g' -e 's/".*//g' | head -n 1
{
"filter": {
	"from":"now-2w",
	"query": "@correlation_id:$1 @body.email_address:*@*",
	"to": "now"
	},
"options": {
        "timezone": "GMT"
        },
"page": {
       "limit": 1000
        }
}
EOF

#"indexes"="["main","index-3-days","index-7-days","index-30-days"],
#	"query": "@haproxy.response.code:200 AND @http.url_details.path:\/sessions\/trans\/_sessions_* AND @haproxy.request.header.X-Mogo-Client:android-v4.15.1",
