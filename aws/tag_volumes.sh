#!/bin/bash
#
# Set tag 'Name' for current EC2 instance
# ---------------------------------------
#
# Usage:
#   ./tag_volumes.sh
#
# Expected that you are using NVMe volumes. It will add tag Name
# in format: 'hostname: mount point'.
#
# Dependencies: ec2metadata, nvme, aws
#
# Policy to be able modify volume on EC2 instance:
#
# {
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "VisualEditor0",
#            "Effect": "Allow",
#            "Action": [
#                "ec2:DeleteTags",
#                "ec2:CreateTags"
#            ],
#            "Resource": "arn:aws:ec2:*:AWS_ACCOUNT_ID:volume/*"
#        }
#    ]
# }

REGION=$(ec2metadata | sed -n '/availability-zone/{s/.*: \(.*\)./\1/p}')

for nvme_dev in $(nvme list |\
        grep -Eo '/dev/nvme[0-9]n[0-9](p[0-9])?' | grep -v 'p[0-9]$');
do
    vol_id=$(nvme id-ctrl $nvme_dev | grep ^sn |\
          sed -e 's/.*vol\([[:xdigit:]]*\)/vol-\1/');
    mnt=$(findmnt $nvme_dev -o TARGET -n);
    [ -z "$mnt" ] && mnt="root"

    aws ec2 create-tags --region=$REGION --resources $vol_id \
        --tags "Key=\"Name\",Value=\"$(hostname): $mnt\""
done
