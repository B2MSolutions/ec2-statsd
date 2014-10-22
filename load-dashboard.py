import json
import sys
import urllib
# wget http://monitor.elemez.com/dashboard/load/main -O dashboard-main.json
jason = json.dumps(json.load(open('dashboard-main.json', 'r'))['state'])
post = "state=" + urllib.quote(jason)
result = json.load(urllib.urlopen('http://monitor.elemez.com/dashboard/save/main', data=post))
print result
