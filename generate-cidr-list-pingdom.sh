#!/bin/bash
# This generates a CIDR list of the IPv4 IPs of all Pingdom probe servers.
# Requires curl

# Check for command
function check_command {
	type -P $1 &>/dev/null || fail "Unable to find $1, please install it and run this script again."
}

# Fail
function fail(){
	tput setaf 1; echo "Failure: $*" && tput sgr0
	exit 1
}

# Generate CIDR notation
function GenerateCIDR(){
	while read iplist
	do
		if ! echo $iplist | egrep -q '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$'; then
			echo $iplist/32 >> iplist3
		else echo $iplist >> iplist3
		fi
	done < iplist
	mv iplist3 iplist
}

# Check required commands
check_command "curl"

curl -s https://my.pingdom.com/probes/ipv4 > iplist

GenerateCIDR
