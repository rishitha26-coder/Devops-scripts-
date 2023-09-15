import os
from dateutil.parser import parse as dateutil_parser
from datadog_api_client.v2 import ApiClient, ApiException, Configuration
from datadog_api_client.v2.api import logs_api
from datadog_api_client.v2.models import *
from pprint import pprint
# See configuration.py for a list of all supported configuration parameters.
configuration = Configuration()

# Enter a context with an instance of the API client
with ApiClient(configuration) as api_client:
    # Create an instance of the API class
    api_instance = logs_api.LogsApi(api_client)
    body = LogsListRequest(
        filter=LogsQueryFilter(
            _from="now-2w",
            indexes=["main","index-3-days","index-7-days","index-30-days"],
            query="@haproxy.response.code:200 @http.url_details.path:\/sessions\/trans\/_sessions_* @haproxy.request.header.X-Mogo-Client:android-v4.15.1",
            to="now",
        ),
        options=LogsQueryOptions(
            time_offset=1,
            timezone="GMT",
        ),
        page=LogsListRequestPage(
            cursor="eyJzdGFydEF0IjoiQVFBQUFYS2tMS3pPbm40NGV3QUFBQUJCV0V0clRFdDZVbG8zY3pCRmNsbHJiVmxDWlEifQ==",
            limit=500,
        ),
        sort=LogsSort("timestamp"),
    )  # LogsListRequest |  (optional)

    # example passing only required values which don't have defaults set
    # and optional values
    try:
        # Search logs
        api_response = api_instance.list_logs(body=body)
        pprint(api_response)
    except ApiException as e:
        print("Exception when calling LogsApi->list_logs: %s\n" % e)
