#!/bin/bash
#
# Get list of AWS Relational Database Services (RDS) and free
# storage space for earch instance.
#
# Author: Martin 'BruXy' Bruchanov (bruchy at gmail)
#

###########
# Globals #
###########

REGIONS=(eu-west-1 eu-west-2 us-east-1)
declare -A RDS_INSTANCES
START="$(date -u -d '5 minutes ago' '+%Y-%m-%dT%T')"
END="$(date -u '+%Y-%m-%dT%T')"
OUTPUT=1 #0 for ';' delimited CSV, 1 for ASCII table
HEADER="Name;Region;DB Engine;Type;Size;Avail;Used"

#############
# Functions #
#############

#=== FUNCTION ============================================================
#        Name: get_metric
# Description: Query AWS CloudWatch metric for average value for the
#              interval between $START and $END
# Parameter 1: AWS Region.
# Parameter 2: RDS Name (DBInstanceIdentifier).
# Parameter 3: Metric Name.
#     Returns: Value or empty string to stdout.
#=========================================================================

function get_metric() {
    local region=$1
    local db_name=$2
    local metric=$3

    AWS_DEFAULT_REGION="$region" \
    aws cloudwatch get-metric-statistics \
        --namespace AWS/RDS --metric-name "$metric" \
        --start-time $START --end-time $END --period 300 \
        --statistics Average \
        --dimensions "Name=DBInstanceIdentifier, Value=${db_name}" \
        --output=text \
        --query "Datapoints[].[Average]"
}

#=== FUNCTION ============================================================
#        Name: format_table
# Description: Format output as table or CSV, default according to $OUTPUT.
#=========================================================================

function format_table() {
    if [ $OUTPUT -eq 1 ] ; then # Table format
        sed -e "1i $HEADER" | \
            column -s';' -t | \
            sed '1{p;s/./-/g}'
    else # CSV format
        sed -e "1i $HEADER"
    fi
}

########
# Main #
########

# List databases and some parameters in REGIONS:
# ----------------------------------------------
#
#   * DBInstanceIdentifier
#   * DBInstanceClass
#   * Engine
#   * EngineVersion
#   * AvailabilityZone
#   * AllocatedStorage (in gibibytes, converted to bytes)
#
# Output is available in hash arrad RDS_INSTANCES
#
# RDS_INSTANCES[Id]="Type Engine-Version Size Region"

while read line
do
    id=$(cut -f 1 <<< "$line")
    data=$(cut -f 2- <<< "$line")
    RDS_INSTANCES[$id]="$data"
done <<< "$(
    for region in ${REGIONS[*]}
    do
        aws rds describe-db-instances --region=$region \
            --output=text --query \
            "DBInstances[].[DBInstanceIdentifier,DBInstanceClass,
            Engine,EngineVersion,AllocatedStorage,AvailabilityZone]" |
        while read DB TYPE ENGINE VERSION DISK AZ
        do
            printf "%s\t%s\t%s-%s\t%u\t%s\n" $DB $TYPE $ENGINE \
                $VERSION $[DISK*10**9] ${AZ:0:-1}
        done
    done
)"

# Display free space for each RDS instance
# ----------------------------------------
#

for i in ${!RDS_INSTANCES[@]}
do
    name=$i
    region=$(cut -f 4 <<< "${RDS_INSTANCES[$i]}")
    total=$(cut -f 3 <<< "${RDS_INSTANCES[$i]}")
    engine=$(cut -f 2 <<< "${RDS_INSTANCES[$i]}")
    inst_type=$(cut -f 1 <<< "${RDS_INSTANCES[$i]}")
    free_space=$(get_metric $region $name FreeStorageSpace )

    if [ -z "$free_space" ] ; then
        free_space=$(get_metric $region $name FreeLocalStorage )
        # If FreeStorage is not available, it is probably DB cluster
        # and then allocated space is lower then FreeLocal so the
        # percentage does not make sense.
        used_percent='N/A'
    else
        used_percent=$(bc <<< "scale=2;(($total-$free_space)*100)/$total+0.05")
    fi

    # Convert bytes to IEC (K, M, G, base 1024)
    free_space=$(numfmt --to=iec <<< $free_space)
    total=$(numfmt --to=iec <<< $total)

    printf "%s;%s;%s;%s;%s;%s;%s %%\n" $name $region $engine \
        $inst_type $total $free_space $used_percent
done | format_table

