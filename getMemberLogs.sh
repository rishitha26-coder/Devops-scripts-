#!/bin/bash

. /Volumes/Private\ Keys/datadog.config

# Curl command
curl -X POST "https://api.datadoghq.com/api/v2/logs/events/search" \
-H "Content-Type: application/json" \
-H "DD-API-KEY: ${DD_API_KEY}" \
-H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
-d @- << EOF 2> /dev/null 
{
"filter": {
	"from":"now-2w",
	"query": "@member_uuid:$2 -source:http_service",
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
