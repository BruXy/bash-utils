#!/bin/bash
#
# Accordint to the Terraform template, the AWS account ID is stored in the
# config file. This script will read the config file and set the AWS
# environment variables accordingly.
#

setenv() {
    source ~/.bash_sources/aws_env.sh
    _git_root=$(git rev-parse --show-toplevel)

    mapfile -t _env_list < <(
        grep ^account_id $_git_root/config/*.tfvars |\
            sed -E 's#.*/([^/]+)\.tfvars.*= "([0-9]*)"#\1 \2#'
        )

    printf "Found environment(s):\n"
    printf -- "---------------------\n"
    select environ in "${_env_list[@]}"
    do
        aenv ${environ#* }
        break
    done
}

