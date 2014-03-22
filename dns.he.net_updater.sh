#!/bin/bash

url="https://dyn.dns.he.net/nic/update"
previous_file_prefix=~/.dyndns

retval=0

use_ifconfig='no' # set this to 'yes' to use ifconfig to determine local IP addresses.
iface='eth0' # only needed if $use_ifconfig='yes'

for hostname_password in \
  "hostname1:password1" \
  "hostname2:password2" #etc...
do

  hostname=$( /bin/echo -n "$hostname_password" | /bin/sed 's/:[^:]*//' )
  password=$( /bin/echo -n "$hostname_password" | /bin/sed 's/[^:]*://' )

  previous_file="${previous_file_prefix}.${hostname}"
  previous=$(cat "${previous_file}" 2>/dev/null)

  currentip=''
  if [ "$use_private_ip" == "yes" ]; then
    if which ip >/dev/null 2>&1; then
      currentip=$(ip addr show dev eth0 | grep inet\ .*scope\ global | sed -E 's/[^0-9]*([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\/[0-9]{1,2}.*/\1/g')
    elif which ifconfig >/dev/null 2>&1; then
      currentip=$(ifconfig en0 inet | grep -E '^.*inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*$' | sed -E 's/^.*inet ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*$/\1/')
    else
      /usr/bin/logger -i -t com.bennettp123.dyndns "${hostname}: could not determine local IP address"
      retval=1
      break
    fi
  else
    currentip=$(/usr/bin/curl -4 -s "http://checkip.dns.he.net" | /bin/grep -iE "Your ?IP ?address ?is ?: ?" | /bin/sed -r 's/.*\s+([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}).*/\1/')
  fi

  oldip=$(echo "${previous}" \
            | /bin/grep "${hostname}" \
            | /bin/sed -r 's/.*\s+([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}).*/\1/')

  if [ "_$oldip" = "_" ]; then
    oldip="unknown"
  fi

  if [ "_$currentip" != "_$oldip" ]; then
    /usr/bin/logger -i -t com.bennettp123.dyndns "${hostname}: old ip: ${oldip}; current ip: ${currentip}; updating..."
    result1=$(/usr/bin/curl -4 -s "${url}" -d "hostname=${hostname}" -d "password=${password}")
    retval1=$?
    /usr/bin/logger -i -t com.bennettp123.dyndns "${hostname}:${result1}"
    echo "${hostname}:${result1}" > "${previous_file}"
  else
    /usr/bin/logger -i -t com.bennettp123.dyndns "${hostname}: old ip: ${oldip}; current ip: ${currentip}; not updating"
    retval1=0
  fi

  retval=`bc <<EOF
    $retval1 + $retval
EOF
`

done

exit $retval
