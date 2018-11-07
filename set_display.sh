#!/bin/bash
#
# Try to determine X11's DISPLAY port when it is not set.
#
# Use: source ./set_display.sh to modify your current shell session!
#

function set_display() {
    port=$( ([ $(w|sed -n '2s/.*FROM.*/1/p') -eq '1' ] && w || w -f) |\
            grep -Eo ' :[0-9]+')
    if [ -z "$port" ] ; then
        [ -t 0 ] && printf "Cannot determine DISPLAY port" >&2
        return 1
    else
        [ -t 0 ] && printf "Setting DISPLAY=%s\n" $port >&2
        printf $port
        return 0
    fi
}

export DISPLAY=$(set_display)

