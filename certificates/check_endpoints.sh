#!/bin/bash
#
# Check API endpoint certificates
# -------------------------------
#
# Usage: ./api_endpoints_check.sh FILE|HOSTNAME1 HOSTNAME2 ...
#
# Also stdin can be used to pipe a list of endpoints into the script.
#
source libcert.sh

if [ $# -lt 1 ] && [ -t 0 ]; then
    sed -n '/^set /{q;};s/^#//g;/bash/d;p' $0
    exit 1
fi

# Read endpoints from stdin, file or command line arguments
if [[ ! -t 0 ]]; then
    mapfile -t URL
elif test -f $1; then
  echo "Using $1 as the list of endpoints to check"
  mapfile -t URL < $1
else
  URL=( "$@" )
fi

( echo "|API Endpoint|Expiration|Issuer|"
echo "|------------|----------|------|"
( for ENDPOINT in ${URL[*]}; do
   echo -n "|$ENDPOINT|"
   if RAW_CERT_DATA="$( get_raw_certificate $ENDPOINT )"; then
        EXPIRATION_DATE="$( echo "$RAW_CERT_DATA" | check_expiration )"
        ISSUER="$( echo "$RAW_CERT_DATA" | get_issuer )"
        echo "$EXPIRATION_DATE|$ISSUER|"
     else
        echo -n "ERROR: $RAW_CERT_DATA|ERROR: $RAW_CERT_DATA|"
     fi 
done | sort ) ) | column -s'|' -o'|' -t | sed '/^|[- ]*|/ s/ /-/g'

