from datadog import initialize, api
from time import time
from json import dump
import sys,os

sys.path.append(os.path.expanduser("~/.secrets"))

from datadogConfig import *

initialize(**options)

end = int(time())  # Specify the time period over which you want to fetch the data in seconds
start = end - int(sys.argv[2])

query = 'sys.argv[1]'  # Enter the metric you want, see your list here: https://app.datadoghq.com/metric/summary.
                              # Optionally, enter your host to filter the data, see here: https://app.datadoghq.com/infrastructure

#from dateutil.parser import parse as dateutil_parser
#from datadog_api_client.v2 import ApiClient, ApiException, Configuration
#from datadog_api_client.v2.api import logs_api
#from datadog_api_client.v2.models import *
#from datadog_api_client.v2 import logs_api
#from pprint import pprint

results = api.v2.logs.events.search(start=start - 3600, end=end, query=query)

print results

with open("output.json", "w") as f:
  dump(results, f)
  # This creates a file named output.json in the current folder
