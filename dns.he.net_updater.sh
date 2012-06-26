#!/bin/bash

hostname="HOSTNAME"
password="PASSWORD"
url="https://dyn.dns.he.net/nic/update"

result=$(/usr/bin/curl -4 -k -s "https://dyn.dns.he.net/nic/update" -d "hostname=${hostname}" -d "password=${password}")
retval=$?

# Custom IP Address:
#myip=$(ifconfig en0 inet | grep -E '^.*inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*$' | sed -E 's/^.*inet ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*$/\1/')
#result=$(/usr/bin/curl -4 -k -s "https://dyn.dns.he.net/nic/update" -d "hostname=${hostname}" -d "password=${password}" -d "myip=${ipaddr}")

# Proxy support:
#proxy="localhost:3128"
#result=$(/usr/bin/curl -4 -x "${proxy}" -k -s "https://dyn.dns.he.net/nic/update" -d "hostname=${hostname}" -d "password=${password}" -d "myip=${ipaddr}")

/usr/bin/logger -i -s -t com.bennettp123.dyndns "${hostname} ${result}"

exit $retval

