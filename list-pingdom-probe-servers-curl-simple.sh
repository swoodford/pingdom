#!/bin/bash
# This script lists the IPv4 addresses of all Pingdom probe servers.
# Requires curl.

# More info:
# https://help.pingdom.com/hc/en-us/articles/203682601-Pingdom-probe-servers-IP-addresses

# Check for command
function check_command {
	type -P $1 &>/dev/null || fail "Unable to find $1, please install it and run this script again."
}

# Fail
function fail(){
	tput setaf 1; echo "Failure: $*" && tput sgr0
	exit 1
}

# Check required commands
check_command "curl"

curl -s https://my.pingdom.com/probes/ipv4 | \
grep -v NULL
