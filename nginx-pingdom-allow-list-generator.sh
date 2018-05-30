#!/usr/bin/env bash

# This script generates an Nginx allow list conf from a list of Pingdom probe server IPv4 addresses.
# Requires curl.

# More info:
# https://help.pingdom.com/hc/en-us/articles/203682601-Pingdom-probe-servers-IP-addresses
# http://nginx.org/en/docs/http/ngx_http_access_module.html

# Variables
outputfilename="nginx-pingdom-allowlist.conf"

# Check for command
function check_command {
	type -P $1 &>/dev/null || fail "Unable to find $1, please install it and run this script again."
}

# Fail
function fail(){
	tput setaf 1; echo "Failure: $*" && tput sgr0
	exit 1
}

check_command "curl"

if [ -f pingdom ] || [ -f temp ] || [ -f '$outputfilename' ]; then
	rm -f pingdom temp '$outputfilename'
fi

# Get Pingdom probe IPs
curl -s https://my.pingdom.com/probes/ipv4 | grep -v NULL > pingdom
if ! [ -f pingdom ] || [ $(wc -l pingdom | rev | cut -d " " -f2 | rev) -lt 3 ]; then
	fail "Unable to fetch Pingdom probe server IPs."
fi

# Generate Nginx conf
while read allowlist
do
	echo "allow "$allowlist"/32;" >> temp
done < pingdom

rm pingdom
mv temp "$outputfilename"

echo "Nginx allow list conf generated: $outputfilename"
