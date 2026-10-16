#!/bin/bash
#
# Download EC2 Launch Templates Data
#
# Usage:
# get-lt-versions.sh LaunchTemplateId Version1 [Version2 ... VersionN]
#
LT=${1:?"Please provide a launch template ID!."}
shift
VERSIONS="${@}"
[ -z "$VERSIONS" ] && {
    echo "Please provide one or more launch template versions."
    exit 1
}

for version in $VERSIONS
do
    printf -v output_file "%s-v%s.data" "$LT" "$version"
    printf "Saving version '%s' of launch template '%s' to file '%s'\n" "$version" "$LT" "$output_file"
    aws ec2 describe-launch-template-versions \
        --launch-template-id "$LT" --versions $version \
        --query 'LaunchTemplateVersions[].LaunchTemplateData.UserData' \
        --output text | base64 -d > "$output_file"
done

