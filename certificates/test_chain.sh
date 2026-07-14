#!/bin/bash
#
# Testing validity of certificate chain file
# ==========================================
#
# Usage:
#   ./test_chain.sh <cert_chain_file>
#
# FROM RFC 4346
# https://www.rfc-editor.org/rfc/rfc4346#section-7.4.2
#
#   certificate_list
#       This is a sequence (chain) of X.509v3 certificates.  The sender's
#       certificate must come first in the list.  Each following
#       certificate must directly certify the one preceding it.  Because
#       certificate validation requires that root keys be distributed
#       independently, the self-signed certificate that specifies the root
#       certificate authority may optionally be omitted from the chain,
#       under the assumption that the remote end must already possess it
#       in order to validate it in any case.
#
set -uo pipefail
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source $SCRIPT_DIR/libcert.sh

INPUT=${1:?"Please provide certificate file!"}
TMP_DIR=$(mktemp -d crt-chk-XXXX)
TMP_PREFIX="crt-"
ERR_CODE=0
DEBUG=0

function split_chain() {
    in=$1
    csplit -s -z -f "${TMP_DIR}/${TMP_PREFIX}" "$in" \
        '/-----BEGIN CERTIFICATE-----/' '{*}'
    certs=$(ls ${TMP_DIR}/* | wc -l)
    [ $DEBUG -ne 0 ] && printf "$0: Found %d certificates\n" $certs
}

function check_validity() {
    in="$1"
    time_fmt='+%B %-d, %Y'
    $OPENSSL_BIN x509 -noout -dates -in "$in" |\
        while read -r from && read -r to
        do
            printf "Valid from %s to %s.\n" \
                "$(date -d "${from#*=}" "$time_fmt")" \
                "$(date -d "${to#*=}" "$time_fmt")"
        done
}

function check_crt() {
    in=$1
    index=$((${in/*$TMP_PREFIX/}+0))
    next=$(printf "%s/%s%02d" "$TMP_DIR" "$TMP_PREFIX" "$((index+1))")

    printf "\nPosition in chain: %s\n" $index

    cur_subject=$(get_subject "$in")

    cur_issuer=$(get_issuer "$in")

    printf "Subject: %s\n" "$cur_subject"
    printf "Issued by: %s\n" "$cur_issuer"
    check_sans "$in"
    check_validity "$in"
    get_fingerprint "$in"

    if [[ "$cur_subject" == "$cur_issuer" ]] ; then
        printf "Root certificate (or self-signed).\n"
    fi

    if [ -f "$next" ] ; then
        next_subject=$(get_subject "$next")

        if [[ "$cur_issuer" == "$next_subject" ]] ; then
            check_crt "$next"
        else
            printf "${RED_BOLD}ERROR: Next certificate is not issuer of the previous one!${RESET}\n"
            printf "Issuer: %s\n" "$next_subject"
            check_crt "$next"
            ERR_CODE=1
        fi
    else
        return
    fi
}

########
# Main #
########

[ $DEBUG -ne 0 ] && printf "$0: Using temporary directory: %s\n" "$TMP_DIR"
split_chain "$INPUT"

# Recursive function start from the first item
check_crt "${TMP_DIR}/${TMP_PREFIX}00"

# Clean up
[ $DEBUG -ne 0 ] && rm -rf "$TMP_DIR"

# $ERR_CODE is set inside check_crt() function
if [ $ERR_CODE -ne 0 ] ; then
    printf "\n${RED_BOLD}ERROR: Certificate chain is invalid, check order of certificates!${RESET}\n"
    exit 1
fi

