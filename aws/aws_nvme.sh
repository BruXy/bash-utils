#!/bin/bash
#
# Display AWS device mappings
#

# Check for dependencies
nvme version > /dev/null || {
    printf "Please install 'nvme-cli' package first!\n"
    exit 1
}

# Display devices
( printf "AWS console;Volume Id;Local device\n"
for nvme_dev in $(nvme list | grep -Eo '/dev/nvme[0-9]n[0-9](p[0-9])?' | grep -v 'p[0-9]$')
do
    aws_dev=$(nvme id-ctrl -v $nvme_dev | grep '^0000' | grep -Eo '(/dev/)?[a-z]{3,4}')
    aws_id=$(nvme id-ctrl -v $nvme_dev | sed -ne '/^sn/{s/.*: //;p}')

    if [[ $aws_id == vol* ]] ; then
        aws_id=${aws_id/vol/vol-}
    else
        aws_dev="ephemeral" # volume id should start with 'AWS'
    fi

    if [[ $aws_dev != "ephemeral" ]] && [[ $aws_dev != /dev/* ]] ; then
        aws_dev=/dev/$aws_dev
    fi
    printf "%s;%s;%s\n" $aws_dev $aws_id $nvme_dev
done ) | column -s';' -t
