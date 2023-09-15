from datetime import date
import holidays
import sys
import os
import calendar
cal = calendar.Calender()

sys.path.append(os.path.expanduser("~/.secrets"))

from holidayconfig import *

for week in cal.monthdatescalendar(2021,5):
  for date in week: 
     print date
