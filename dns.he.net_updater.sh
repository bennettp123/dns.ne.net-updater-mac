#!/bin/bash

url="https://dyn.dns.he.net/nic/update"
previous_file_prefix=~/.dns.he.net

retval=0

hostname=''
password=''
use_local_iface_address='' # set this to 'yes' to use ifconfig to determine local IP addresses.
iface='eth0' # ignored unless $use_local_iface_address = yes

while getopts 'h:p:li:' optname; do
  case "$optname" in
    'h')
      hostname="$OPTARG"
      ;;
    'p')
      password="$OPTARG"
      ;;
    'l')
      use_local_iface_address='yes'
      ;;
    'i')
      iface="$OPTARG"
      ;;
    ':')
      echo "No argument value for option $OPTARG"
      exit 1
      ;;
    *)
      echo 'Unknown error while processing options'
      exit 1
      ;;
  esac
done

previous_file="${previous_file_prefix}.${hostname}"
previous=$(cat "${previous_file}" 2>/dev/null)

currentip=''
if [ "$use_local_iface_address" == "yes" ]; then
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
  result=$(/usr/bin/curl -4 -s "${url}" -d "hostname=${hostname}" -d "password=${password}")
  retval=$?
  /usr/bin/logger -i -t com.bennettp123.dyndns "${hostname}:${result1}"
  echo "${hostname}:${result1}" > "${previous_file}"
else
  /usr/bin/logger -i -t com.bennettp123.dyndns "${hostname}: old ip: ${oldip}; current ip: ${currentip}; not updating"
  retval=0
fi

exit $retval
