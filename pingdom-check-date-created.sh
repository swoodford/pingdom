#!/bin/bash
# This script lists creation date and time of all Pingdom checks in your account
# Run the script and append its output to a .csv file
# Requires jq (http://stedolan.github.io/jq/download/)

# Set required variables
EMAIL="Your Pingdom Email"
PASSWORD="Your Pingdom Password"
ACCOUNTEMAIL="Your Pingdom Group Account Email"
APPKEY="Your Pingdom API App-Key"

# Make sure the variables have been set
if [ "$EMAIL" = "Your Pingdom Email" ]; then
  echo "Must set variables before running."
  exit 1
fi

# Test if jq already installed, else install it
command -v jq >/dev/null 2>&1 || {
  echo "Installing jq."
  brew install jq
  echo "jq installed."
}

# Get list of all checks
CHECKS=$(curl -s --user $EMAIL:$PASSWORD https://api.pingdom.com/api/2.0/checks -H Account-Email:$ACCOUNTEMAIL -H App-Key:$APPKEY)

# Get list of check ID numbers
CHECKIDS=$(echo "$CHECKS" | jq '.checks | .[] | .id' | nl)
# echo "$CHECKIDS"

# Count number of checks
TOTALCHECKS=$(echo "$CHECKIDS" | wc -l)
# echo $TOTALCHECKS


START=1
for (( COUNT=$START; COUNT<=$TOTALCHECKS; COUNT++ ))
do
  # echo \#$COUNT
  
  # Process one check at a time
  CHECK=$(echo "$CHECKIDS" | grep -w $COUNT | cut -f 2)
  # echo "Check ID: "$CHECK
  
  # Get detailed information on check
  DETAILEDCHECK=$(curl -s --user $EMAIL:$PASSWORD https://api.pingdom.com/api/2.0/checks/$CHECK -H Account-Email:$ACCOUNTEMAIL -H App-Key:$APPKEY)
  # echo "$DETAILEDCHECK"

  # Get name of check
  NAME=$(echo "$DETAILEDCHECK" | jq '.check | .name ' | cut -d '"' -f 2)
  # echo "Check Name: "$NAME

  # Get check created timestamp
  CREATED=$(echo "$DETAILEDCHECK" | jq '.check | .created ')

  # Convert timestamp to human readable form
  DATECREATED=$(date -r $CREATED)
  # echo $DATECREATED

  # Output data in CSV format
  echo $DATECREATED,$NAME
done
