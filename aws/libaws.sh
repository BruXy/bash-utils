#!/bin/bash

#=== FUNCTION ============================================================
#        Name: get_ec2_list
# Description: Obtains a list of running EC2 instances and returns them in
#              a sorted array.
#     Returns: An array of running EC2 instances in the format:
#              [0]="Name (InstanceId)" [1]="Name (InstanceId)" ...
#
#              Array needs to be captured by 'eval' to properly used.
#=========================================================================

get_ec2_list() {
    mapfile -t _instance_list < <(aws ec2 describe-instances \
        --filters Name=instance-state-name,Values=running \
        --query 'sort_by(Reservations[].Instances[], &Tags[?Key==`Name`]|[0].Value)[].{
                Name:Tags[?Key==`Name`]|[0].Value,
                Instance:InstanceId
             }' | jq -r '.[]|"\(.Name)|\(.Instance)"'
    )

    if [ ${#_instance_list[*]} -eq 0 ] ; then
        printf "No EC2 instances found!\n" >&2
        exit 1
    fi

    # Format nicely with separated columns.
    mapfile -t _instance_list < <( for _i in "${_instance_list[@]}"
          do
               printf "$_i\n"
          done | column -t -s'|' -o' ' )

    # Return the list of instances as a string.
    set | grep ^_instance_list= | sed -e 's/^_instance_list=//'
}

select_ec2() {
    COLUMNS=20
    local _ec2_list=("$@")
    select _name in "${_ec2_list[@]}"; do
        [[ -n "$_name" ]] || continue
        _selection="${_name}"
        break
    done
    grep -oE 'i-([0-9a-f]{8}|[0-9a-f]{17})' <<< "$_selection"
}

