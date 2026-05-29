#!/bin/bash
#
# aenv -- AWS Provile selector
# ============================
#
# To use this script read it in current shell with `source ./aws_env.sh` and
# then use command `env [regex]`. Optional regex will help you filter profile
# name in case of having too many of them :) It will set in your shell:
# 
#  * AWS_PROFILE
#  * AWS_DEFAULT_REGION
#  * AWS_COLOR -- can be used for example to modify PS1 variable
#
# It expects that your `~/.aws/.config` exits with many profiles defined.
# It also reads profiles between lines 'Roles from' and '#END'.
#
# Example of profile entry:
#
#     [profile example_profile]
#     role_arn = arn:aws:iam::123456789000:role/CloudOps
#     source_profile = cloudops
#     region =  eu-central-1
#     role_name =  CloudOps
#     color =  0000ff
#

hexcolor_to_ansi() {
    local hex="${1#\#}"   # remove leading # if present

    # validate length
    if [[ ${#hex} -ne 6 ]]; then
        echo "Invalid hex colour (expected 6 chars)" >&2
        return 1
    fi

    # extract RGB
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    # output ANSI escape (foreground)
    printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

function read_profiles(){
    PROFILES=()
    while read profile id region color
    do
        PROFILES+=( $(printf "%s%s/%s...(%s)\033[0m" "$(hexcolor_to_ansi $color)" $profile $id $region ))
    done < <(sed -n '
    /Roles from/,/^#END/{
    /^\[profile /{
        x
        s/\n/ /g
        /./p
        x
        s/^\[profile \(.*\)\]/\1/
        h
        d
    }
    /^color =/{ s/^color =\s*/ /; H; d }
    /^region =/{ s/^region =\s*/ /; H; d }
    /^role_arn =/{ s/^role_arn = arn:aws:iam::\([0-9]*\).*/ \1/; H; d }
    ${
        x
        s/\n//g
        p
    }
    }
    ' ~/.aws/config | grep --color=never -E "$ENV_REGEX" )
}

function aenv() {
    ENV_REGEX=${1:-.}
    read_profiles
    COLUMNS=20
    select profile in ${PROFILES[*]}
    do
        selected=$(sed -e 's|^\x1b.*[0-9]m\([^/]*\)/.*|\1|g' <<< "$profile")
        region=$(sed -e 's/.*(\(.*\))\x1b.*/\1/' <<< "$profile")
        color=$(sed -n 's/^\x1b\[38;2;\([0-9;]*\)m.*/\1/p' <<< "$profile")
        export AWS_DEFAULT_REGION=$region
        export AWS_COLOR=$color
        export AWS_PROFILE=$selected
        break
    done
}

