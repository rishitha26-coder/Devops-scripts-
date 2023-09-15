#!/usr/bin/python

from urllib2 import Request, urlopen, URLError
import sys
import json
import base64
import os
import datetime

sys.path.append(os.path.expanduser("~/.secrets"))

from jiraconfig import *


# Jira settings
#JIRA_URL = "https://JIRA_NAME.atlassian.net"

#JIRA_USERNAME = "USER_NAME"
#JIRA_PASSWORD = "" # For Jira Cloud use a token generated here: https://id.atlassian.com/manage/api-tokens

#JIRA_PROJECT_KEY = "TEST"
#JIRA_ISSUE_TYPE = "Story"

USER = os.environ.get('USER')

def jira_rest_call(data):

    # Set the root JIRA URL, and encode the username and password
    url = JIRA_URL + '/rest/api/2/issue'
    base64string = base64.encodestring('%s:%s' % (JIRA_USERNAME, JIRA_PASSWORD)).replace('\n','')

    # Build the request
    restreq = Request(url)
    restreq.add_header('Content-Type', 'application/json')
    restreq.add_header("Authorization", "Basic %s" % base64string)

    # Send the request and grab JSON response
    response = urlopen(restreq, data)

    # Load into a JSON object and return that to the calling function
    return json.loads(response.read())


def generate_summary(summary):
    return summary + ' - {date:%Y-%m-%d %H:%M}'.format(date=datetime.datetime.now())


def generate_description(data):
    return data


def generate_issue_data(summary, description):
    # Build the JSON to post to JIRA
    json_data = '''
    {
        "fields":{
            "project":{
                "key":"%s"
            },
            "summary": "%s",
            "issuetype":{
                "name":"%s"
            },
            "description": "%s"
             },
            "assignee":{"name":"%s@mogo.ca"}

    } ''' % (JIRA_PROJECT_KEY, summary, JIRA_ISSUE_TYPE, description, USER)
    return json_data


json_response = jira_rest_call(generate_issue_data(generate_summary(sys.argv[1]), generate_description(sys.argv[2]) ))
issue_key = json_response['key']
print "Created issue ", issue_key
