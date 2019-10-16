#!/bin/bash
( printf "AWS console;Volume Id;Local device\n"
for nvme_dev in $(nvme list | grep -Eo '/dev/nvme[0-9]n[0-9](p[0-9])?' | grep -v 'p[0-9]$')
do
    aws_dev=$(nvme id-ctrl -v $nvme_dev | grep '^0000' | grep -Eo '(/dev/)?[a-z]{3,4}')
    aws_id=$(nvme id-ctrl -v $nvme_dev | sed -ne '/^sn/{s/.*vol\([[:xdigit:]]*\)/vol-\1/;p}')

    if [[ $aws_dev != /dev/* ]] ; then
        aws_dev=/dev/$aws_dev
    fi
    printf "%s;%s;%s\n" $aws_dev $aws_id $nvme_dev
done ) | column -s';' -t
