#!/bin/bash
# This script converts all Pingdom checks that begin with a lowercase letter in the name to uppercase for proper sorting
# Requires jq (http://stedolan.github.io/jq/download/)

# Set required variables
EMAIL="Your Pingdom Email"
PASSWORD="Your Pingdom Password"
ACCOUNTEMAIL="Your Pingdom Group Account Email"
APPKEY="Your Pingdom API App Key"
APIURL="https://api.pingdom.com/api/2.1"

# Make sure the variables have been set
if [ "$EMAIL" = "Your Pingdom Email" ]; then
  echo "Must set variables before running."
  exit 1
fi

# Functions

# Check for command
function check_command {
    type -P $1 &>/dev/null || fail "Unable to find $1, please install it and run this script again."
}

# Fail
function fail(){
    tput setaf 1; echo "Failure: $*" && tput sgr0
    exit 1
}

# Horizontal Rule
function HorizontalRule(){
    echo "============================================================"
}

# Completed
function completed(){
  echo
  HorizontalRule
  tput setaf 2; echo "Completed!" && tput sgr0
  HorizontalRule
  echo
}

# Check required commands
check_command "jq"
check_command "curl"

# Get list of all checks
CHECKS=$(curl -s --user $EMAIL:$PASSWORD $APIURL/checks -H Account-Email:$ACCOUNTEMAIL -H App-Key:$APPKEY)

# Attempt to test for errors
if echo "$CHECKS" | jq '.error[]' 2>/dev/null; then
  fail "$CHECKS"
fi

# May error with a false positive
# if echo "$CHECKS" | egrep -q "Bad|bad|Error|Invalid|invalid|Not|not"; then
#   fail "$CHECKS"
# fi

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
  DETAILEDCHECK=$(curl -s --user $EMAIL:$PASSWORD $APIURL/checks/$CHECK -H Account-Email:$ACCOUNTEMAIL -H App-Key:$APPKEY)
  # echo "$DETAILEDCHECK"

  # Get name of check
  NAME=$(echo "$DETAILEDCHECK" | jq '.check | .name ' | cut -d '"' -f 2)

  # Grep for lowercase name
  if echo "$NAME" | grep -q ^[a-z]; then
    # Convert first letter to uppercase
    NAME=$(echo "$NAME" | tr '[:lower:]' '[:upper:]' <<< ${NAME:0:1})${NAME:1}

    echo "Check ID: "$CHECK
    echo "Converting:" "$NAME"

    # Modify the name
    UPDATENAME=$(curl -s --user $EMAIL:$PASSWORD \
    -H Account-Email:$ACCOUNTEMAIL \
    -H App-Key:$APPKEY \
    -X PUT \
    $APIURL/checks/$CHECK?name=$NAME
    )

    # Attempt to test for errors
    if echo "$UPDATENAME" | egrep -q "Bad|bad|Error|error|Invalid|invalid|Not|not"; then
      fail "$UPDATENAME"
    else
      echo "$UPDATENAME" | jq .
    fi
  fi

done
