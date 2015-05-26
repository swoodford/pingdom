#!/bin/bash
# This script lists the IPs of all Pingdom probe servers

# More info:
# https://support.pingdom.com/Knowledgebase/Article/View/16/0/where-can-i-find-a-list-of-ip-addresses-for-the-pingdom-probe-servers

wget --quiet -O- https://my.pingdom.com/probes/feed | \
grep "pingdom:ip" | \
sed -e 's|</.*||' -e 's|.*>||' | \
sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4

