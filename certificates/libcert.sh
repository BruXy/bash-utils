#!/bin/bash
#set -euo pipefail

DATE_FMT='%Y-%b-%d %A'

# %Y ... Year (e.g. 2024)
# %b ... Short months name (e.g. Nov)
# %d ... Day of month (01-31)
# %A ... Full weekday name (e.g. Friday)

RED_BOLD='\033[1;31m'
RESET='\033[0m'

# MacOS uses LibreSSL by default. We install the latest OpenSSL version through brew and use it
[[ -f "/usr/local/opt/openssl/bin/openssl" ]] && \
    export OPENSSL_BIN=/usr/local/opt/openssl/bin/openssl || \
    export OPENSSL_BIN=/usr/bin/openssl

function unix2days() {
    local unix_time=$1

    # Truncate UNIX time to 10 bytes to cut miliseconds if present
    unix_time=${unix_time:0:10}
    today_unix=$(date +%s)
    days_to_expiration=$[(unix_time - today_unix)/(24*3600)]
    not_after=$(date -d @${unix_time} "+$DATE_FMT")

    if [ $days_to_expiration -gt 0 ] ; then
        printf "In %d days (%s)." $days_to_expiration "$not_after"
    else
        printf "Already expired on: %s." "$not_after"
    fi
}

function get_raw_certificate() {
    local host=$1

    # Add :443 only if no port is specified at the end
    [[ ! "$host" =~ :[0-9]+$ ]] && host="${host}:443"

    $OPENSSL_BIN s_client -showcerts -connect $host </dev/null 2>/dev/null |\
    sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p'

    if [ $? -ne 0 ] ; then
        printf "Error: Could not retrieve certificate from %s\n" "$host"
        return 1
    fi
}

function get_issuer() {
    local input=${1:-/dev/stdin}

    $OPENSSL_BIN x509 -noout -issuer -nameopt RFC2253 -in "$input" |\
        sed -e 's/issuer=//' | sed -e 's/[A-Z]*=//g' | sed -e 's/,/, /g'
}

function get_subject() {
    local input=${1:-/dev/stdin}

    $OPENSSL_BIN x509 -noout -subject -nameopt RFC2253 -in "$input" |\
        sed -e 's/^subject=//' | sed -e 's/[A-Z]*=//g' | sed -e 's/,/, /g'
}

function get_fingerprint() {
    local input=${1:-/dev/stdin}

    $OPENSSL_BIN x509 -noout -fingerprint -in "$input"
}

function check_expiration() {
    local input=${1:-/dev/stdin}

    not_after=$(${OPENSSL_BIN} x509 -noout -enddate -in $input |\
         sed -e 's/notAfter=//')

    unix2days $(date +%s -d "$not_after")
}


function check_sans() {
    local input=${1:-/dev/stdin}

    retval=$(openssl x509 -noout -ext subjectAltName -in "$input" 2>&1)
    if [[ "$retval" != "No extensions in certificate" ]] ; then
        grep 'DNS:' <<< "$retval" | sed -e 's/^[[:space:]]*//g' -e 's/DNS:/& /g'
    else
        return
    fi
}


function time_unix2date() {
    local unix_time=$1
    # Truncate UNIX time to 10 bytes to cut miliseconds if present
    not_after=$(date -d @${unix_time:0:10})
    printf "%s" "$not_after"
}


function get_modulus_cert() {
    local input=${1:-/dev/stdin}

    $OPENSSL_BIN x509 -modulus -noout -in $input |\
        $OPENSSL_BIN md5 | sed 's/MD5(stdin)= //'
}

function get_modulus_key() {
    local input=${1:-/dev/stdin}

    $OPENSSL_BIN rsa -modulus -noout -in $input |\
        $OPENSSL_BIN md5 | sed 's/MD5(stdin)= //'
}

function modulus_equal() {
    local cert_modulo=$1
    local key_modulo=$2

    if [[ "$cert_modulo" != "$key_modulo" ]] ; then
        printf "Certificate and private key does not match!\n"
        echo "Cert: $cert_modulo"
        echo "Key: $key_modulo"
        return 1
    fi
}
