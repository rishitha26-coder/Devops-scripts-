import calendarific

with open('/Volumes/Private Keys/calendarific.key', 'r') as myfile:
	calapi = calendarific.v2(myfile.read().replace('\n',''))

parameters = {
  'country': 'CA', 'year': '2021' }

print calapi.holidays(parameters)
