#!/bin/bash
#%A
#
# AWS SSH connector
# =================
#
# Simplify list and connection to Linux server infrastructure.
#
# COMMANDS:
#
# aws_instances.sh [[l]ist|[c]onnect]|[t]able] [-h|-help|[h]elp]
#
# Note: can be shortened up to first letter:
#
# * list    - default display of running instances
# * table   - list running instances in CSV format with ';' separator
# * connect - list instances and select one for SSH connection
# * help    - display this help
#
# Use this example to update your ~/.ssh/config:
# ----------------------------------------------
#
# Development and production may run in different AWS regions, both
# environments have a different subnet for networking. They have also
# different SSH keys.
#
# * development: 172.31.*
# * produciton: 10.20.*
#
# For automatic connecting to those internal subnets (via VPN) update
# ~/.ssh/config:
#
# Host 172.31.*
#    IdentityFile ~/.ssh/test-server-key.pem
#    User ubuntu
#    IdentitiesOnly yes
#
# Host 10.20.*
#   IdentityFile ~/.ssh/production-key.pem
#   User ubuntu
#   IdentitiesOnly yes
#
#%B

####################
# Global variables #
####################

REGIONS=(us-east-1 us-east-2)
TMP_SEL=/tmp/menu-selector-$$
#SSH_OPTS="-i ~/.ssh/id_rsa_aws"
CHECK_DIALOG=${CHECK_DIALOG=1} # Disable if you do not want use connector menu

#############
# Functions #
#############

function usage() {
    sed -n '/^#%A/,/^#%B/s/#[%AB]*//p' $0
}


function check_deps() {
    if [ "$CHECK_DIALOG" -eq 1 ] ; then
        dialog --version > /dev/null || {
    cat 1>&2 << EOF
Install 'dialog' first!
Dialog provides user-friendly dialog boxes from shell scripts.
    sudo apt-get install dialog

If you do not want to use dialog for 'connect' command set CHECK_DIALOG to 0.
    export CHECK_DIALOG=0

EOF
            echo "Install 'dialog' first!" 1>&2; exit 1;
        }
    fi
    aws --version > /dev/null || {
    cat 1>&2 << EOF
Install 'awscli' first!
    sudo pip install awscli --upgrade

Configure your AWS credentials:
    https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

EOF
    exit 1
    }
}


function aws_instances()
{
  local aws_region
  for aws_region in ${REGIONS[*]}
  do
    aws ec2 --region "${aws_region}" describe-instances | \
      jq  -cr ".Reservations[].Instances[] |
    ( [ ((.Tags[]? // {} | select(.Key == \"Name\") | .Value) // \"(none)\",
         \"; \",
         (.PublicIpAddress | if . == \"\" then \"(none)\" else . end) // \"(none)\",
        \"; \",
         (.PrivateIpAddress | if . == \"\" then \"(none)\" else . end) // \"(none)\"),
        \"; \",
        .InstanceType,
        \"; $aws_region\"
      ] | add )"
  done | sort
}


function table_header() {
    echo "Name; PublicIpAddress; PrivateIpAddress; InstanceType; Region   "
}


function list_csv() {
    table_header
    aws_instances
}


function list() {
    (
        table_header
        aws_instances
    ) | column -s';' -t | sed '1{p;s/./-/g}'

}


function dialog_list() {
    while read line
    do
        name=$(cut -d';' -f 1 <<< $line)
        priv_ip=$(cut -d';' -f 3 <<< $line)
        printf "\"%s\" \"%s\"\n" "$name" $priv_ip
    done <<< "$(aws_instances)"
}


function ssh_menu() {
    # dialog need this trick to display items correctly!
    local list=$(dialog_list)
    menu_generator="dialog --clear \
        --backtitle 'AWS SSH connector' \
        --title 'List of AWS instances' \
        --menu 'Choose one of the following options:' 30 80 27 \
        $list
    "
    eval $menu_generator 2>"$TMP_SEL"
    [ $? -ne 0 ] && exit 1
    host_ip=$(grep "$(cat $TMP_SEL)" <<< "$list" | grep -oE "([0-9]{1,3}\.?){4}")
    ssh $SSH_OPTS $host_ip
}


########
# Main #
########

[[ "$*" =~ -h ]] && { usage; exit 0; }

check_deps
cmd=${1:-list} # if not specified, do list by default

case $cmd in
    l*) # lst, list, ...
        list
    ;;
    c*) # con, connect, ...
        ssh_menu $2
        rm -f $TMP_SEL
    ;;
    t*) # table
        list_csv
    ;;
    h*) # help
        usage
    ;;
esac
