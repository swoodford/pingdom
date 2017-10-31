#!/bin/bash
# This script lists the IPs of all Pingdom probe servers.
# Requires wget.

# More info:
# https://help.pingdom.com/hc/en-us/articles/203682601-Pingdom-probe-servers-IP-addresses

function check_command {
	type -P $1 &>/dev/null || fail "Unable to find $1, please install it and run this script again."
}

# Check required commands
check_command "wget"

wget --quiet -O- https://my.pingdom.com/probes/feed | \
grep "pingdom:ip" | \
sed -e 's|</.*||' -e 's|.*>||' | \
sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | \
grep -v NULL
