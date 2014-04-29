#!/bin/bash

USAGE="Usage:
 $(basename $0) -h <fqdn> -p <password> [-l] [i <iface>]
 $(basename $0) --help

 -h <fqdn>     : The hostname to update
 -p <password> : The password to use
 -l            : Set using local interface address
 -i <iface>    : The interface to use when getting local address. Implies -l

By default, $(basename $0) queries dns.he.net to determine the public IP address.
When called with -l or -i, it uses the address of a local interface instead.
"

# detect sed syntax
sed_ex_sw='-E' #default
for sw in '-r' '-E'; do
  if echo 1 | sed "$sw" 's/1/2/' 2>&1 | grep --silent 2; then
    sed_ex_sw="$sw"
    break
  fi
done

url="https://dyn.dns.he.net/nic/update"
previous_file_prefix=~/.dns.he.net

retval=0

hostname=''
password=''
use_local_iface_address='' # set this to 'yes' to use ifconfig to determine local IP addresses.
iface='eth0' # ignored unless $use_local_iface_address = yes

if [ "$1" == "--help" ]; then
  printf "%s\n" "$USAGE"
  exit 0
fi

while getopts 'h:p:li:h' optname; do
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
      use_local_iface_address='yes'
      iface="$OPTARG"
      ;;
    ':')
      echo "No argument value for option $OPTARG"
      printf "%s\n" "$USAGE"
      exit 1
      ;;
    *)
      echo 'Unknown error while processing options'
      printf "%s\n" "$USAGE"
      exit 1
      ;;
  esac
done

previous_file="${previous_file_prefix}.${hostname}"
previous=$(cat "${previous_file}" 2>/dev/null)

currentip=''
if [ "$use_local_iface_address" == "yes" ]; then
  if which ip >/dev/null 2>&1; then
    currentip=$(ip addr show dev eth0 | grep inet\ .*scope\ global | sed "$sed_ex_sw" 's/[^0-9]*([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\/[0-9]{1,2}.*/\1/g')
  elif which ifconfig >/dev/null 2>&1; then
    currentip=$(ifconfig en0 inet | grep -E '^.*inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*$' | sed "$sed_ex_sw" 's/^.*inet ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*$/\1/')
  else
    logger -i -t com.bennettp123.dyndns "${hostname}: could not determine local IP address"
    retval=1
    break
  fi
else
  currentip=$(curl -4 -s "http://checkip.dns.he.net" | grep -iE "Your ?IP ?address ?is ?: ?" | sed "$sed_ex_sw" 's/.*\s+([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}).*/\1/')
fi

oldip=$(echo "${previous}" \
          | grep "${hostname}" \
          | sed "$sed_ex_sw" 's/.*\s+([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}).*/\1/')

if [ "_$oldip" = "_" ]; then
  oldip="unknown"
fi

if [ "_$currentip" != "_$oldip" ]; then
  logger -i -t com.bennettp123.dyndns "${hostname}: old ip: ${oldip}; current ip: ${currentip}; updating..."
  result=$(curl -k -4 -s "${url}" -d "hostname=${hostname}" -d "password=${password}" -w '%{http_code}')
  retval=$?
  logger -i -t com.bennettp123.dyndns "${hostname}:${result}"
  echo "${hostname}:${result}" > "${previous_file}"
else
  logger -i -t com.bennettp123.dyndns "${hostname}: old ip: ${oldip}; current ip: ${currentip}; not updating"
  retval=0
fi

exit $retval
